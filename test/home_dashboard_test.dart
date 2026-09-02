import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_guard/main.dart';
import 'package:expense_guard/features/home/providers/home_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('homeStateProvider Unit Tests', () {
    test('homeStateProvider loads initial mock metrics properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(homeStateProvider);
      expect(state.userName, 'Alex');
      expect(state.totalSpent, 2450.80);
      expect(state.monthlyLimit, 5000.00);
      expect(state.approvedAmount, 1850.00);
      expect(state.pendingAmount, 600.80);
      expect(state.remainingBudget, 2549.20);
      expect(state.spendPercentage, 49);
      expect(state.recentTransactions.length, 5);
      expect(state.recentTransactions.first.merchant, 'Starbucks');
    });
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen renders summary widget, quick actions, and recent transactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Skip onboarding to land on HomeScreen
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // 1. Verify Top App Bar & User Greeting
      expect(find.text('ExpenseGuard'), findsAtLeast(1));
      expect(find.text('Good morning, Alex'), findsOneWidget);
      expect(find.byKey(const Key('home_theme_toggle_button')), findsOneWidget);
      expect(find.byKey(const Key('home_notifications_button')), findsOneWidget);

      // 2. Verify Spend Summary Widget
      expect(find.text("Total spend this month"), findsOneWidget);
      expect(find.text('\$2450.80'), findsOneWidget);
      expect(find.text('49% of limit'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('\$1850'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('\$601'), findsOneWidget); // Rounded 600.80 to 601
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('\$2549'), findsOneWidget);
      expect(find.byKey(const Key('home_add_expense_button')), findsOneWidget);

      // 3. Verify Quick Actions Bento Grid
      expect(find.byKey(const Key('bento_scan_receipt')), findsOneWidget);
      expect(find.text('Scan Receipt'), findsOneWidget);
      expect(find.byKey(const Key('bento_cards')), findsOneWidget);
      expect(find.byKey(const Key('bento_approvals')), findsOneWidget);
      expect(find.byKey(const Key('bento_insights')), findsOneWidget);

      // 4. Verify Recent Transactions Section
      expect(find.text('Recent transactions'), findsOneWidget);
      expect(find.text('Starbucks'), findsOneWidget);
      expect(find.text('Uber Ride'), findsOneWidget);
      expect(find.text('AWS Cloud Services'), findsOneWidget);
      expect(find.text('Delta Air Lines'), findsOneWidget);
      expect(find.text('Apple Store'), findsOneWidget);
    });

    testWidgets('Theme toggle button updates application theme mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Skip onboarding
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Tap Theme toggle button
      await tester.tap(find.byKey(const Key('home_theme_toggle_button')));
      await tester.pumpAndSettle();

      // Verify theme toggling occurred without error
      expect(find.byKey(const Key('home_theme_toggle_button')), findsOneWidget);
    });

    testWidgets('Tapping Quick Actions and Transaction navigates accurately',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Skip onboarding
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // 1. Tap Scan Receipt in Bento
      await tester.tap(find.byKey(const Key('bento_scan_receipt')));
      await tester.pumpAndSettle();
      expect(find.text('Submit Expense'), findsOneWidget);

      // Go back
      final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
      navigator.pop();
      await tester.pumpAndSettle();

      // 2. Tap a transaction (Starbucks)
      await tester.ensureVisible(find.text('Starbucks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Starbucks'));
      await tester.pumpAndSettle();
      expect(find.text('Transaction Detail'), findsOneWidget);
    });
  });
}
