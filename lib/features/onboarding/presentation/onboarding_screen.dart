import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/onboarding/providers/onboarding_provider.dart';

/// Data class representing an onboarding slide.
class OnboardingSlide {
  const OnboardingSlide({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.accentDim,
    required this.illustrationType,
  });

  final String tag;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color accentDim;
  final String illustrationType;
}

/// The Onboarding Screen featuring PageView slides and Pastel Flat design tokens.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeAndNavigateHome() async {
    // 1. Update Riverpod provider
    await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();

    // 2. Directly ensure SharedPreferences persistence
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kOnboardingCompleteKey, true);
    } catch (_) {}

    // 3. Navigate to /home using GoRouter
    if (mounted) {
      context.go('/home');
    }
  }

  void _nextPage(int totalSlides) {
    if (_currentPage < totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeAndNavigateHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    final slides = [
      OnboardingSlide(
        tag: 'AI Smart Capture',
        title: 'Smart Corporate Spending',
        description:
            'Capture receipts instantly with AI auto-fill, seamless currency conversion, and automatic line-item categorization.',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: colors.mint,
        accentDim: colors.mintDim,
        illustrationType: 'wallet',
      ),
      OnboardingSlide(
        tag: 'Real-time Guard',
        title: 'Instant Policy Guardrails',
        description:
            'Stay compliant automatically. ExpenseGuard flags limits and policy violations before submission to prevent delays.',
        icon: Icons.verified_user_rounded,
        accentColor: colors.lavender,
        accentDim: colors.lavenderDim,
        illustrationType: 'shield',
      ),
      OnboardingSlide(
        tag: 'Cards & Analytics',
        title: 'Frictionless Approvals',
        description:
            'Manage corporate cards, set monthly budget limits, and approve or route expenses in a single frictionless tap.',
        icon: Icons.credit_card_rounded,
        accentColor: colors.peach,
        accentDim: colors.peachDim,
        illustrationType: 'card',
      ),
    ];

    final isLastSlide = _currentPage == slides.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.mint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.borderDark,
                  width: AppTheme.borderWidth,
                ),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 18,
                color: colors.borderDark,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ExpenseGuard',
              style: context.headlineMd.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          if (!isLastSlide)
            TextButton(
              onPressed: _completeAndNavigateHome,
              child: Text(
                'Skip',
                style: context.labelMd.copyWith(
                  color: colors.borderDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Slide Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _SlideView(slide: slides[index]);
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.marginMobile,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (index) {
                      final isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: isSelected ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? slides[_currentPage].accentColor
                              : colors.tagBackground,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: colors.borderDark,
                            width: 1.0,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Primary Button (Next or Get Started)
                  ElevatedButton(
                    key: const Key('onboarding_primary_button'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastSlide ? colors.peach : colors.mint,
                      foregroundColor: colors.borderDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        side: BorderSide(
                          color: colors.borderDark,
                          width: AppTheme.borderWidth,
                        ),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _nextPage(slides.length),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastSlide ? 'Get Started' : 'Next',
                          style: context.labelMd.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.borderDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastSlide
                              ? Icons.arrow_forward_rounded
                              : Icons.navigate_next_rounded,
                          size: 20,
                          color: colors.borderDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // SSO Button option (matches Stitch pastel flat button)
                  OutlinedButton(
                    key: const Key('onboarding_sso_button'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: colors.borderDark,
                        width: AppTheme.borderWidth,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    onPressed: _completeAndNavigateHome,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Continue with SSO',
                          style: context.labelMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide presentation widget with custom Pastel Flat illustration.
class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Illustration container
          _PastelIllustrationCard(slide: slide),
          const SizedBox(height: 32),

          // Tag badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: slide.accentColor,
              borderRadius: BorderRadius.circular(AppTheme.chipRadius),
              border: Border.all(
                color: colors.borderDark,
                width: 1.2,
              ),
            ),
            child: Text(
              slide.tag,
              style: context.labelMd.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.borderDark,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            slide.title,
            style: context.headlineLg.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            slide.description,
            style: context.bodyMd.copyWith(
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Neo-brutalist / Pastel Flat illustration graphic.
class _PastelIllustrationCard extends StatelessWidget {
  const _PastelIllustrationCard({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: slide.accentDim,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative geometric shapes
          Positioned(
            top: 24,
            right: 32,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.skyBlue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.borderDark, width: 1.2),
              ),
              child: const Icon(Icons.star_rounded, size: 20),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 32,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.peach,
                shape: BoxShape.circle,
                border: Border.all(color: colors.borderDark, width: 1.2),
              ),
              child: const Icon(Icons.bolt_rounded, size: 18),
            ),
          ),

          // Main Hero Pastel Card
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: slide.accentColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.borderDark,
                width: 2.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  slide.icon,
                  size: 56,
                  color: colors.borderDark,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.borderDark, width: 1.0),
                  ),
                  child: Text(
                    'ExpenseGuard',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colors.borderDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
