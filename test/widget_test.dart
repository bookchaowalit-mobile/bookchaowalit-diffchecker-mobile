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
}
