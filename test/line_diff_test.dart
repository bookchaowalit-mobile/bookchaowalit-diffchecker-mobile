import 'package:diffchecker/logic/line_diff.dart';
import 'package:flutter_test/flutter_test.dart';

const same = DiffOp.same;
const add = DiffOp.added;
const del = DiffOp.removed;

void main() {
  test('identical texts produce only unchanged lines', () {
    final d = diffLines('a\nb', 'a\nb\n');
    expect(d, const [DiffLine(same, 'a'), DiffLine(same, 'b')]);
    expect(summarise(d).identical, isTrue);
  });

  test('replacement and append', () {
    final d =
        diffLines('apple\nbanana\ncherry', 'apple\nblueberry\ncherry\ndate');
    expect(d, const [
      DiffLine(same, 'apple'),
      DiffLine(del, 'banana'),
      DiffLine(add, 'blueberry'),
      DiffLine(same, 'cherry'),
      DiffLine(add, 'date'),
    ]);
    final s = summarise(d);
    expect([s.added, s.removed, s.unchanged], [2, 1, 2]);
  });

  test('empty sides', () {
    expect(diffLines('', ''), isEmpty);
    expect(diffLines('', 'x'), const [DiffLine(add, 'x')]);
    expect(diffLines('x', ''), const [DiffLine(del, 'x')]);
  });

  test('CRLF and LF are treated the same', () {
    expect(summarise(diffLines('a\r\nb\r\n', 'a\nb')).identical, isTrue);
  });

  test('ignoreWhitespace compares normalised lines', () {
    expect(summarise(diffLines('a  b', ' a b ')).identical, isFalse);
    expect(
      diffLines('a  b', ' a b ', ignoreWhitespace: true),
      const [DiffLine(same, ' a b ')],
    );
  });

  test('uses the longest common subsequence', () {
    final d = diffLines('a\nb\nc\nd', 'b\nc\nd\na');
    expect(summarise(d).unchanged, 3);
    expect(d.first, const DiffLine(del, 'a'));
    expect(d.last, const DiffLine(add, 'a'));
  });

  test('rejects oversized inputs', () {
    final big = List.filled(maxDiffLines + 1, 'x').join('\n');
    expect(() => diffLines(big, ''), throwsArgumentError);
  });

  test('toString prefixes', () {
    expect(const DiffLine(add, 'x').toString(), '+ x');
    expect(const DiffLine(del, 'x').toString(), '- x');
    expect(const DiffLine(same, 'x').toString(), '  x');
  });

  group('edge cases (pass 3)', () {
    test('large files with a small change are no longer rejected', () {
      final lines = List.generate(maxDiffLines * 3, (i) => 'line $i');
      final changed = [...lines]..[maxDiffLines] = 'edited';
      final d = diffLines(lines.join('\n'), changed.join('\n'));
      final s = summarise(d);
      expect(s.added, 1);
      expect(s.removed, 1);
      expect(s.unchanged, maxDiffLines * 3 - 1);
      expect(d[maxDiffLines], const DiffLine(del, 'line $maxDiffLines'));
      expect(d[maxDiffLines + 1], const DiffLine(add, 'edited'));
      expect(d.last, const DiffLine(same, 'line ${maxDiffLines * 3 - 1}'));
    });

    test('the limit still applies to a large changed section', () {
      final left = List.generate(maxDiffLines + 1, (i) => 'a$i').join('\n');
      final right = List.generate(maxDiffLines + 1, (i) => 'b$i').join('\n');
      expect(() => diffLines(left, right), throwsArgumentError);
    });

    test('lone CR line endings split lines', () {
      expect(splitLines('a\rb\r'), ['a', 'b']);
      expect(summarise(diffLines('a\rb', 'a\nb')).identical, isTrue);
    });

    test('blank lines and whitespace-only lines', () {
      expect(splitLines('\n'), ['']);
      expect(splitLines('\n\n'), ['', '']);
      final d = diffLines('a\n\nb', 'a\n   \nb', ignoreWhitespace: true);
      expect(summarise(d).identical, isTrue);
      expect(d[1], const DiffLine(same, '   '));
      expect(summarise(diffLines('a\n\nb', 'a\n   \nb')).identical, isFalse);
    });

    test('prefix/suffix trimming respects ignoreWhitespace', () {
      final d = diffLines(' x\nmid\ny ', 'x\nMID\ny', ignoreWhitespace: true);
      expect(d, const [
        DiffLine(same, 'x'),
        DiffLine(del, 'mid'),
        DiffLine(add, 'MID'),
        DiffLine(same, 'y'),
      ]);
    });

    test('repeated lines and unicode', () {
      final d = diffLines('ก\nก\nก', 'ก\nก');
      expect(summarise(d).unchanged, 2);
      expect(summarise(d).removed, 1);
      expect(
          summarise(diffLines('😀 a', '😀  a', ignoreWhitespace: true))
              .identical,
          isTrue);
    });

    test('one side empty', () {
      expect(diffLines('', 'a\nb'),
          const [DiffLine(add, 'a'), DiffLine(add, 'b')]);
      expect(diffLines('a', ''), const [DiffLine(del, 'a')]);
      expect(diffLines('', ''), isEmpty);
    });
  });
}
