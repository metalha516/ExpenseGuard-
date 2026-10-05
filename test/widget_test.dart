import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/main.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/core/router/scaffold_with_nav_bar.dart';

void main() {
  testWidgets('ExpenseGuardApp mounts and starts at /onboarding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ExpenseGuardApp()));
    await tester.pumpAndSettle();

    // Verify initial route displays onboarding content
    expect(find.text('Welcome to ExpenseGuard'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Navigating to /home displays bottom navigation bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ExpenseGuardApp()));
    await tester.pumpAndSettle();

    // Tap Get Started button to navigate to /home
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Home Screen and Persistent Bottom Navigation Bar
    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.byType(ScaffoldWithNavBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Approvals'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('AppTheme extensions provide expected pastel colors in Light and Dark mode',
      (WidgetTester tester) async {
    final lightColors = AppPastelColors.light;
    final darkColors = AppPastelColors.dark;

    expect(lightColors.mint, const Color(0xFFB5EAD7));
    expect(lightColors.borderDark, const Color(0xFF1A1C1E));
    expect(darkColors.mint, const Color(0xFFB5EAD7));
    expect(darkColors.borderDark, const Color(0xFF1A1C1E));
  });
}
