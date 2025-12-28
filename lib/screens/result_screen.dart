import 'package:flutter/material.dart';
import '../models/decision.dart';
import '../widgets/confidence_bar.dart';

class ResultScreen extends StatefulWidget {
  final Decision decision;

  const ResultScreen({super.key, required this.decision});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Decision'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question text
              Text(
                widget.decision.question,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Main result card with fade + scale animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Card(
                    elevation: 4,
                    color: colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 48.0,
                      ),
                      child: Column(
                        children: [
                          // Decision icon
                          Icon(
                            Icons.auto_awesome,
                            size: 48,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 24),

                          // Large headline decision
                          Text(
                            widget.decision.selectedChoice,
                            style: textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Reason text
                          Text(
                            widget.decision.reason,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Confidence indicator with animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: _AnimatedConfidenceWrapper(
                  targetConfidence: widget.decision.confidence,
                ),
              ),
              const SizedBox(height: 48),

              // Action button
              FadeTransition(
                opacity: _fadeAnimation,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Another Decision'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    textStyle: textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedConfidenceWrapper extends StatefulWidget {
  final int targetConfidence;

  const _AnimatedConfidenceWrapper({required this.targetConfidence});

  @override
  State<_AnimatedConfidenceWrapper> createState() =>
      _AnimatedConfidenceWrapperState();
}

class _AnimatedConfidenceWrapperState
    extends State<_AnimatedConfidenceWrapper> {
  int _currentConfidence = 0;

  @override
  void initState() {
    super.initState();
    // Trigger animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentConfidence = widget.targetConfidence;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConfidenceBar(confidence: _currentConfidence);
  }
}
