import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier managing application ThemeMode state with SharedPreferences persistence.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _prefKey = 'expense_guard_theme_mode';

  @override
  ThemeMode build() {
    _loadPersistedTheme();
    return ThemeMode.system;
  }

  /// Load theme mode from local storage.
  Future<void> _loadPersistedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'light') {
        state = ThemeMode.light;
      } else if (saved == 'dark') {
        state = ThemeMode.dark;
      } else if (saved == 'system') {
        state = ThemeMode.system;
      }
    } catch (_) {
      // Gracefully fall back to system default if SharedPreferences is unavailable
    }
  }

  /// Explicitly set theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode.name);
    } catch (_) {}
  }

  /// Toggle between Light and Dark modes.
  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  /// Set to light mode.
  Future<void> setLight() async => setThemeMode(ThemeMode.light);

  /// Set to dark mode.
  Future<void> setDark() async => setThemeMode(ThemeMode.dark);

  /// Reset to system preference.
  Future<void> setSystem() async => setThemeMode(ThemeMode.system);
}

/// Riverpod provider for application theme mode.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
