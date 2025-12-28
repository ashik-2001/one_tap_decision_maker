import 'package:flutter/material.dart';

class ConfidenceBar extends StatelessWidget {
  final int confidence;
  final Duration duration;

  const ConfidenceBar({
    super.key,
    required this.confidence,
    this.duration = const Duration(seconds: 1),
  });

  @override
  Widget build(BuildContext context) {
    // Ensure confidence is between 0 and 100
    final int clampedConfidence = confidence.clamp(0, 100);
    
    return Column(
      children: [
        Text(
          'Confidence level: $clampedConfidence%',
          style: Theme.of(context).textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final double targetWidth = maxWidth * (clampedConfidence / 100);

            return Container(
              height: 20,
              width: maxWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: targetWidth,
                height: 20,
                decoration: BoxDecoration(
                  color: _getColor(clampedConfidence, context),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getColor(int confidence, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (confidence >= 80) return scheme.primary;
    if (confidence >= 50) return scheme.secondary;
    return scheme.error;
  }
}
