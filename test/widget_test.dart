import 'package:diffchecker/main.dart';
import 'package:diffchecker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell shows diff and about tab', (tester) async {
    await tester.pumpWidget(const DiffcheckerApp());
    expect(find.text('Diffchecker'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('summary reacts to edits', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('+2 added, -1 removed'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('left-input')), 'same');
    await tester.enterText(find.byKey(const Key('right-input')), 'same');
    await tester.pump();
    expect(find.text('No differences'), findsOneWidget);
  });

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const HomeScreen(),
        ),
      );

  testWidgets('whitespace toggle hides whitespace-only changes', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    await tester.enterText(find.byKey(const Key('left-input')), 'a  b');
    await tester.enterText(find.byKey(const Key('right-input')), 'a b');
    await tester.pump();
    expect(find.text('+1 added, -1 removed'), findsOneWidget);
    await tester.tap(find.text('Ignore whitespace'));
    await tester.pump();
    expect(find.text('No differences'), findsOneWidget);
  });

  testWidgets('an oversized changed section shows an error, not a crash', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    await tester.enterText(
      find.byKey(const Key('left-input')),
      List.generate(2001, (i) => 'a$i').join('\n'),
    );
    await tester.enterText(
      find.byKey(const Key('right-input')),
      List.generate(2001, (i) => 'b$i').join('\n'),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('diff-error')), findsOneWidget);
    expect(find.byKey(const Key('diff-summary')), findsNothing);
  });

  testWidgets('diff lines have readable semantics labels', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    expect(find.bySemanticsLabel('Added: blueberry'), findsOneWidget);
    expect(find.bySemanticsLabel('Removed: banana'), findsOneWidget);
    expect(find.bySemanticsLabel('Unchanged: apple'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale without overflow', (tester) async {
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
