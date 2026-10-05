import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for tracking onboarding completion.
const String kOnboardingCompleteKey = 'has_completed_onboarding';

/// Notifier that manages and persists onboarding completion state in modern Riverpod.
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    checkStatus();
    return false;
  }

  /// Check persisted status from SharedPreferences.
  Future<void> checkStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(kOnboardingCompleteKey) ?? false;
    } catch (_) {
      state = false;
    }
  }

  /// Mark onboarding as completed in memory and storage.
  Future<void> completeOnboarding() async {
    state = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kOnboardingCompleteKey, true);
    } catch (_) {}
  }

  /// Reset onboarding status (useful for logout or testing).
  Future<void> resetOnboarding() async {
    state = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kOnboardingCompleteKey);
    } catch (_) {}
  }
}

/// Provider exposing whether onboarding has been completed.
final onboardingCompletedProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
