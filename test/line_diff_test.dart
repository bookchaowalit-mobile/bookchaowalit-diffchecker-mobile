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
}
