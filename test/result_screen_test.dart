import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decision_maker/models/decision.dart';
import 'package:decision_maker/screens/result_screen.dart';

void main() {
  testWidgets('Result Screen displays decision details', (WidgetTester tester) async {
    final decision = Decision(
      question: 'Should I test this?',
      selectedChoice: 'Yes',
      reason: 'Testing is crucial.',
      confidence: 95,
    );

    await tester.pumpWidget(MaterialApp(
      home: ResultScreen(decision: decision),
    ));

    // Wait for animations
    await tester.pumpAndSettle();

    // Verify static text
    expect(find.text('The Decision'), findsOneWidget);
    expect(find.text('Should I test this?'), findsOneWidget);
    
    // Verify animated/revealed text
    // Animations take time, so we might need to pump frames
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('Testing is crucial.'), findsOneWidget);
    expect(find.text('Testing is crucial.'), findsOneWidget);
    
    // ConfidenceBar displays specific text format
    expect(find.text('Confidence level: 95%'), findsOneWidget);
    // Verify ConfidenceBar widget is present
    // Import path might be needed or just checking by type if exported or checking internal text is enough.
    // Since we check the text, that confirms the widget or at least the text is there.

    // Verify button
    expect(find.text('Try Another Decision'), findsOneWidget);
  });
}
