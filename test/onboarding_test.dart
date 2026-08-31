import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_guard/main.dart';
import 'package:expense_guard/features/onboarding/providers/onboarding_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('OnboardingScreen displays slides, navigates with Next, and completes with Get Started',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verify Slide 1
    expect(find.text('Smart Corporate Spending'), findsOneWidget);
    expect(find.text('AI Smart Capture'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap Next to go to Slide 2
    await tester.tap(find.byKey(const Key('onboarding_primary_button')));
    await tester.pumpAndSettle();

    // Verify Slide 2
    expect(find.text('Instant Policy Guardrails'), findsOneWidget);
    expect(find.text('Real-time Guard'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap Next to go to Slide 3
    await tester.tap(find.byKey(const Key('onboarding_primary_button')));
    await tester.pumpAndSettle();

    // Verify Slide 3
    expect(find.text('Frictionless Approvals'), findsOneWidget);
    expect(find.text('Cards & Analytics'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started
    await tester.tap(find.byKey(const Key('onboarding_primary_button')));
    await tester.pumpAndSettle();

    // Verify navigation arrived at /home
    expect(find.text('Good morning, Alex'), findsOneWidget);

    // Verify SharedPreferences flag was updated
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(kOnboardingCompleteKey), true);
  });

  testWidgets('Tapping Skip navigates directly to /home and sets completion flag',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Tap Skip on first slide
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Verify navigation to /home
    expect(find.text('Good morning, Alex'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(kOnboardingCompleteKey), true);
  });
}
