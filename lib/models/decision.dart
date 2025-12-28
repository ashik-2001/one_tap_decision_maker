class Decision {
  final String question;
  final String selectedChoice;
  final String reason;
  final int confidence;

  Decision({
    required this.question,
    required this.selectedChoice,
    required this.reason,
    required this.confidence,
  });

  @override
  String toString() {
    return 'Decision(question: $question, selectedChoice: $selectedChoice, reason: $reason, confidence: $confidence)';
  }
}
