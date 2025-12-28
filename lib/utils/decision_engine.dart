import 'dart:math';
import '../models/decision.dart';

class DecisionEngine {
  final Random _random = Random();

  Decision makeDecision({
    required String question,
    required List<String> choices,
  }) {
    if (choices.isEmpty) {
      throw ArgumentError('Choices cannot be empty');
    }

    final int selectedIndex = _random.nextInt(choices.length);
    final String selectedChoice = choices[selectedIndex];
    
    // Generate confidence between 60 and 95
    final int confidence = 60 + _random.nextInt(36); 

    // Context-aware reasons
    final Map<String, List<String>> reasonMap = {
      'Yes': [
        'The universe signals a go!',
        'This is the path to greatness.',
        'Fortune favors the bold.',
        'All signs point to success.',
        'Trust your gut, do it!',
      ],
      'No': [
        'Better safe than sorry.',
        'Not the right time.',
        'Calculations suggest a pause.',
        'There are better options ahead.',
        'Caution is the better part of valor.',
      ],
      'Default': [
        'This option stands out.',
        'Calculations favor this choice.',
        'My digital intuition points here.',
        'It seems like the logical step.',
        'The data leans this way.',
      ],
    };

    List<String> reasons;
    if (selectedChoice.toLowerCase() == 'yes') {
      reasons = reasonMap['Yes']!;
    } else if (selectedChoice.toLowerCase() == 'no') {
      reasons = reasonMap['No']!;
    } else {
      reasons = reasonMap['Default']!;
    }

    final String reason = reasons[_random.nextInt(reasons.length)];

    return Decision(
      question: question,
      selectedChoice: selectedChoice,
      reason: reason,
      confidence: confidence,
    );
  }
}
