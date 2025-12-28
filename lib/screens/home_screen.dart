import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/decision_engine.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  bool _isCustomMode = false;
  final List<TextEditingController> _optionControllers = [];
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  
  // AdMob Banner
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _addOption();
    _addOption();
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Load banner ad
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111' // Test ad unit ID for Android
        : 'ca-app-pub-3940256099942544/2934735716'; // Test ad unit ID for iOS

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _buttonAnimationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  bool get _canDecide {
    if (_questionController.text.trim().isEmpty) return false;
    if (_isCustomMode) {
      final validOptions = _optionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toSet();
      return validOptions.length >= 2;
    }
    return true;
  }

  void _decide() {
    FocusScope.of(context).unfocus();
    
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    final question = _questionController.text.trim();
    List<String> options;

    if (_isCustomMode) {
      options = _optionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList();
    } else {
      options = ['Yes', 'No'];
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final engine = DecisionEngine();
      final decision = engine.makeDecision(
        question: question,
        choices: options,
      );

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResultScreen(decision: decision),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
            var opacityAnimation = animation.drive(tween);

            return FadeTransition(
              opacity: opacityAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('One Tap Decision Maker'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Card with subtle elevation animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Question',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _questionController,
                          decoration: InputDecoration(
                            hintText: 'What should I decide?',
                            prefixIcon: const Icon(Icons.help_outline),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mode Selection Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Decision Mode',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Yes / No'),
                            avatar: const Icon(Icons.check_circle_outline, size: 18),
                            selected: !_isCustomMode,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _isCustomMode = false);
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Custom Options'),
                            avatar: const Icon(Icons.list, size: 18),
                            selected: _isCustomMode,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _isCustomMode = true);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Custom Options Card with AnimatedSwitcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
                child: _isCustomMode
                    ? Card(
                        key: const ValueKey('custom_options'),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Options',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _optionControllers.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _optionControllers[index],
                                          decoration: InputDecoration(
                                            hintText: 'Option ${index + 1}',
                                            prefixIcon: Icon(
                                              Icons.radio_button_unchecked,
                                              color: colorScheme.primary,
                                            ),
                                            filled: true,
                                            fillColor: colorScheme.surfaceContainerHighest,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: colorScheme.primary,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedScale(
                                        scale: _optionControllers.length > 2 ? 1.0 : 0.8,
                                        duration: const Duration(milliseconds: 200),
                                        child: IconButton(
                                          onPressed: _optionControllers.length > 2
                                              ? () => _removeOption(index)
                                              : null,
                                          icon: const Icon(Icons.remove_circle_outline),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _addOption,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Option'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
              const SizedBox(height: 32),

              // Decide Button with scale animation
              ScaleTransition(
                scale: _buttonScaleAnimation,
                child: FilledButton.icon(
                  onPressed: _canDecide ? _decide : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Decide for Me'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    textStyle: textTheme.titleMedium,
                    elevation: _canDecide ? 2 : 0,
                  ),
                ),
              ),
              
              // Add spacing for banner ad at bottom
              if (_isBannerAdLoaded) const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isBannerAdLoaded && _bannerAd != null
          ? SafeArea(
              child: SizedBox(
                height: 50,
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }
}
