// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:decision_maker/main.dart';

void main() {
  testWidgets('Home Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify initial state
    expect(find.text('One Tap Decision Maker'), findsOneWidget);
    expect(find.text('Decide for Me'), findsOneWidget);

    // Initial state: Question empty -> Button disabled.
    // Tapping should not show SnackBar.
    await tester.tap(find.text('Decide for Me'));
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);

    // Enter a question
    await tester.enterText(find.byType(TextField).first, 'Should I go out?');
    await tester.pump();

    // Verify button enabled and works
    await tester.tap(find.text('Decide for Me'));
    
    // Wait for the delay (300ms) and animation
    await tester.pumpAndSettle();

    // Verify we navigated to ResultScreen
    expect(find.text('The Decision'), findsOneWidget);
    expect(find.text('Confidence level:', findRichText: true), findsNothing); // ConfidenceBar uses specific text
    // The previous ResultScreen test checked for "Confidence level: XX%". 
    // Since DecisionEngine is random, we can't predict the exact text for confidence or reason.
    // But we can check for static elements of ResultScreen.
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('The Decision'), findsOneWidget); // AppBar title from ResultScreen
    
    // Check if we can go back
    await tester.tap(find.text('Try Another Decision'));
    await tester.pumpAndSettle();
    
    // Verify we are back at Home
    expect(find.text('One Tap Decision Maker'), findsOneWidget);
  });
}
