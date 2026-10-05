import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_guard/main.dart';
import 'package:expense_guard/features/home/presentation/main_shell.dart';
import 'package:expense_guard/features/expenses/presentation/submit_expense_camera_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MainShell renders 5 tabs and center docked FAB',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Skip onboarding to enter MainShell
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Verify MainShell is mounted
    expect(find.byType(MainShell), findsOneWidget);

    // Verify all 5 navigation tabs
    expect(find.byKey(const Key('nav_item_home')), findsOneWidget);
    expect(find.byKey(const Key('nav_item_approvals')), findsOneWidget);
    expect(find.byKey(const Key('nav_item_cards')), findsOneWidget);
    expect(find.byKey(const Key('nav_item_insights')), findsOneWidget);
    expect(find.byKey(const Key('nav_item_profile')), findsOneWidget);

    // Verify docked center FAB
    expect(find.byKey(const Key('docked_camera_fab')), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
  });

  testWidgets('Tapping navigation tabs switches active branches',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Skip onboarding
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // 1. Switch to Approvals tab
    await tester.tap(find.byKey(const Key('nav_item_approvals')));
    await tester.pumpAndSettle();
    expect(find.text('Approvals Queue'), findsOneWidget);

    // 2. Switch to Cards tab
    await tester.tap(find.byKey(const Key('nav_item_cards')));
    await tester.pumpAndSettle();
    expect(find.text('Corporate Cards'), findsOneWidget);

    // 3. Switch to Insights tab
    await tester.tap(find.byKey(const Key('nav_item_insights')));
    await tester.pumpAndSettle();
    expect(find.text('Spend Insights'), findsOneWidget);

    // 4. Switch to Profile tab
    await tester.tap(find.byKey(const Key('nav_item_profile')));
    await tester.pumpAndSettle();
    expect(find.text('Profile & Settings'), findsOneWidget);

    // 5. Switch back to Home tab
    await tester.tap(find.byKey(const Key('nav_item_home')));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Alex'), findsOneWidget);
  });

  testWidgets('Tapping docked FAB opens Submit Expense camera flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Skip onboarding
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Tap docked FAB
    await tester.tap(find.byKey(const Key('docked_camera_fab')));
    await tester.pumpAndSettle();

    // Verify navigation to Submit Expense camera screen
    expect(find.byType(SubmitExpenseCameraScreen), findsOneWidget);
    expect(find.text('Position receipt within the frame'), findsOneWidget);
  });
}
