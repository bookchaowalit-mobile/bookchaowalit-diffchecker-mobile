/// Line-based diff using a longest-common-subsequence table.
library;

enum DiffOp { same, added, removed }

class DiffLine {
  const DiffLine(this.op, this.text);

  final DiffOp op;
  final String text;

  String get prefix => switch (op) {
        DiffOp.same => '  ',
        DiffOp.added => '+ ',
        DiffOp.removed => '- ',
      };

  @override
  bool operator ==(Object other) =>
      other is DiffLine && other.op == op && other.text == text;

  @override
  int get hashCode => Object.hash(op, text);

  @override
  String toString() => '$prefix$text';
}

class DiffSummary {
  const DiffSummary(this.added, this.removed, this.unchanged);

  final int added;
  final int removed;
  final int unchanged;

  bool get identical => added == 0 && removed == 0;
}

/// Hard cap to keep the O(n*m) table bounded on a phone.
const maxDiffLines = 2000;

List<String> splitLines(String text) {
  if (text.isEmpty) return const [];
  final lines = text.replaceAll('\r\n', '\n').split('\n');
  if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
  return lines;
}

String _normalise(String line) => line.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Diffs [left] against [right]. Removed lines come before added lines at the
/// same position. When [ignoreWhitespace] is set, lines that differ only in
/// whitespace count as unchanged (the right-hand text is shown).
/// Throws [ArgumentError] when either side exceeds [maxDiffLines].
List<DiffLine> diffLines(
  String left,
  String right, {
  bool ignoreWhitespace = false,
}) {
  final a = splitLines(left);
  final b = splitLines(right);
  if (a.length > maxDiffLines || b.length > maxDiffLines) {
    throw ArgumentError('Each side is limited to $maxDiffLines lines');
  }
  final ka = ignoreWhitespace ? a.map(_normalise).toList() : a;
  final kb = ignoreWhitespace ? b.map(_normalise).toList() : b;
  final n = a.length;
  final m = b.length;
  // lcs[i][j] = LCS length of a[i..] and b[j..].
  final lcs = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      lcs[i][j] = ka[i] == kb[j]
          ? lcs[i + 1][j + 1] + 1
          : (lcs[i + 1][j] >= lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1]);
    }
  }
  final out = <DiffLine>[];
  var i = 0;
  var j = 0;
  while (i < n && j < m) {
    if (ka[i] == kb[j]) {
      out.add(DiffLine(DiffOp.same, b[j]));
      i++;
      j++;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      out.add(DiffLine(DiffOp.removed, a[i++]));
    } else {
      out.add(DiffLine(DiffOp.added, b[j++]));
    }
  }
  while (i < n) {
    out.add(DiffLine(DiffOp.removed, a[i++]));
  }
  while (j < m) {
    out.add(DiffLine(DiffOp.added, b[j++]));
  }
  return out;
}

DiffSummary summarise(List<DiffLine> diff) {
  var added = 0;
  var removed = 0;
  var same = 0;
  for (final d in diff) {
    switch (d.op) {
      case DiffOp.added:
        added++;
      case DiffOp.removed:
        removed++;
      case DiffOp.same:
        same++;
    }
  }
  return DiffSummary(added, removed, same);
}
