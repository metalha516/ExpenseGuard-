import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_guard/main.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/approvals/models/approval_item.dart';
import 'package:expense_guard/features/approvals/presentation/approvals_screen.dart';
import 'package:expense_guard/features/approvals/providers/approvals_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({ThemeMode themeMode = ThemeMode.light}) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const ApprovalsScreen(),
      ),
    );
  }

  group('Approvals Provider Unit Tests', () {
    test('initial state loads mock items with high risk and standard items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(approvalsProvider);
      expect(state.pendingCount, 6);
      expect(state.highRiskCount, 4);
      expect(state.standardCount, 2);
      expect(state.totalPendingAmount, greaterThan(3000.0));

      final alex = state.items.firstWhere((i) => i.id == 'appr-01');
      expect(alex.employeeName, 'Alex Johnson');
      expect(alex.merchant, 'Delta Airlines');
      expect(alex.fraudRiskScore, 85);
      expect(alex.policyWarning, 'Exceeds airfare budget by 24%');
      expect(alex.isHighRisk, isTrue);
    });

    test('approve mutates status to approved and removes from pending', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(approvalsProvider.notifier);
      expect(container.read(approvalsProvider).pendingCount, 6);

      notifier.approve('appr-01');

      final updatedState = container.read(approvalsProvider);
      expect(updatedState.pendingCount, 5);
      final approvedItem =
          updatedState.items.firstWhere((i) => i.id == 'appr-01');
      expect(approvedItem.status, ApprovalStatus.approved);
    });

    test('reject mutates status to rejected and removes from pending', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(approvalsProvider.notifier);
      notifier.reject('appr-02');

      final updatedState = container.read(approvalsProvider);
      expect(updatedState.pendingCount, 5);
      final rejectedItem =
          updatedState.items.firstWhere((i) => i.id == 'appr-02');
      expect(rejectedItem.status, ApprovalStatus.rejected);
    });

    test('undo restores approval item status back to pending', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(approvalsProvider.notifier);
      notifier.approve('appr-01');
      expect(container.read(approvalsProvider).pendingCount, 5);

      notifier.undo('appr-01');
      expect(container.read(approvalsProvider).pendingCount, 6);
    });

    test('filtering by highRisk and standard restricts filteredPendingItems', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(approvalsProvider.notifier);

      notifier.setFilter(ApprovalsFilter.highRisk);
      expect(
        container.read(approvalsProvider).filteredPendingItems.length,
        4,
      );

      notifier.setFilter(ApprovalsFilter.standard);
      expect(
        container.read(approvalsProvider).filteredPendingItems.length,
        2,
      );

      notifier.setFilter(ApprovalsFilter.all);
      expect(
        container.read(approvalsProvider).filteredPendingItems.length,
        6,
      );
    });

    test('search query matches employee, merchant, or policy warning', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(approvalsProvider.notifier);

      notifier.setSearchQuery('Marriott');
      expect(
        container.read(approvalsProvider).filteredPendingItems.length,
        1,
      );
      expect(
        container.read(approvalsProvider).filteredPendingItems.first.merchant,
        'Marriott Downtown',
      );

      notifier.setSearchQuery('airfare');
      expect(
        container.read(approvalsProvider).filteredPendingItems.length,
        1,
      );
    });
  });

  group('ApprovalsScreen Widget Tests', () {
    testWidgets('renders ApprovalsScreen in Light Mode with AI scores and policy warnings',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      // 1. Header & Summary
      expect(find.text('Approvals Queue'), findsOneWidget);
      expect(find.textContaining('items requiring review'), findsOneWidget);
      expect(find.byKey(const Key('approvals_search_toggle_button')), findsOneWidget);

      // 2. Filter Tabs
      expect(find.byKey(const Key('filter_chip_all')), findsOneWidget);
      expect(find.byKey(const Key('filter_chip_high_risk')), findsOneWidget);
      expect(find.byKey(const Key('filter_chip_standard')), findsOneWidget);

      // 3. High Risk Section
      expect(find.text('HIGH RISK / OUT OF POLICY'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.textContaining('Delta Airlines'), findsWidgets);
      expect(find.text('\$840.00'), findsOneWidget);

      // 4. AI Fraud Anomaly Score & Policy Warning
      expect(
        find.textContaining('AI Risk: 85/100 ⚠️ High Anomaly'),
        findsOneWidget,
      );
      expect(
        find.text('Exceeds airfare budget by 24%'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Last minute flight change'),
        findsOneWidget,
      );

      // 5. Standard Routine Section
      expect(find.text('STANDARD ROUTINE'), findsOneWidget);
      expect(find.text('David Kim'), findsOneWidget);
      expect(find.text('\$850.00'), findsOneWidget);
      expect(
        find.textContaining('AI Score: 18/100 ✅ Clean'),
        findsOneWidget,
      );
    });

    testWidgets('renders ApprovalsScreen in Dark Mode cleanly without regressions',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.text('Approvals Queue'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.byKey(const Key('filter_chip_high_risk')), findsOneWidget);
    });

    testWidgets('filtering by High Risk and Standard updates visible cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap High Risk filter chip
      await tester.tap(find.byKey(const Key('filter_chip_high_risk')));
      await tester.pumpAndSettle();

      expect(find.text('HIGH RISK / OUT OF POLICY'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('STANDARD ROUTINE'), findsNothing);
      expect(find.text('David Kim'), findsNothing);

      // Tap Standard filter chip
      await tester.tap(find.byKey(const Key('filter_chip_standard')));
      await tester.pumpAndSettle();

      expect(find.text('HIGH RISK / OUT OF POLICY'), findsNothing);
      expect(find.text('STANDARD ROUTINE'), findsOneWidget);
      expect(find.text('David Kim'), findsOneWidget);

      // Back to All
      await tester.tap(find.byKey(const Key('filter_chip_all')));
      await tester.pumpAndSettle();

      expect(find.text('HIGH RISK / OUT OF POLICY'), findsOneWidget);
      expect(find.text('STANDARD ROUTINE'), findsOneWidget);
    });

    testWidgets('search toggles and filters items dynamically',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap search toggle
      await tester.tap(find.byKey(const Key('approvals_search_toggle_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('approvals_search_field')), findsOneWidget);

      // Enter search term
      await tester.enterText(
        find.byKey(const Key('approvals_search_field')),
        'Marriott',
      );
      await tester.pumpAndSettle();

      expect(find.text('David Kim'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsNothing);

      // Close search
      await tester.tap(find.byKey(const Key('approvals_search_toggle_button')));
      await tester.pumpAndSettle();

      expect(find.text('Alex Johnson'), findsOneWidget);
    });

    testWidgets('swipe right on Dismissible approves item and shows undo SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Alex Johnson'), findsOneWidget);

      // Fling right to approve
      final cardFinder = find.byKey(const Key('approval_dismissible_appr-01'));
      await tester.fling(cardFinder, const Offset(600, 0), 1000);
      await tester.pumpAndSettle();

      // Verify item removed from view
      expect(find.text('Alex Johnson'), findsNothing);

      // Verify SnackBar shown
      expect(find.textContaining('Approved Alex Johnson'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Verify item restored
      expect(find.text('Alex Johnson'), findsOneWidget);
    });

    testWidgets('swipe left on Dismissible flags/rejects item',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final cardFinder = find.byKey(const Key('approval_dismissible_appr-02'));
      await tester.ensureVisible(cardFinder);
      await tester.pumpAndSettle();
      expect(find.text('Jamie Smith'), findsOneWidget);

      // Fling left to flag/reject
      await tester.fling(cardFinder, const Offset(-600, 0), 1000);
      await tester.pumpAndSettle();

      // Verify item removed from view
      expect(find.text('Jamie Smith'), findsNothing);
      expect(find.textContaining('Flagged Jamie Smith'), findsOneWidget);
    });

    testWidgets('direct Approve button tap approves item',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final approveBtn = find.byKey(const Key('approve_button_appr-01'));
      expect(approveBtn, findsOneWidget);

      await tester.tap(approveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Alex Johnson'), findsNothing);
      expect(find.textContaining('Approved Alex Johnson'), findsOneWidget);
    });

    testWidgets('direct Flag button tap rejects item',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final flagBtn = find.byKey(const Key('reject_button_appr-01'));
      expect(flagBtn, findsOneWidget);

      await tester.tap(flagBtn);
      await tester.pumpAndSettle();

      expect(find.text('Alex Johnson'), findsNothing);
      expect(find.textContaining('Flagged Alex Johnson'), findsOneWidget);
    });

    testWidgets('clearing all items displays empty state with reset button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Filter by standard (only 2 items)
      await tester.tap(find.byKey(const Key('filter_chip_standard')));
      await tester.pumpAndSettle();

      // Approve both standard items
      await tester.tap(find.byKey(const Key('approve_button_appr-04')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('approve_button_appr-05')));
      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('All Caught Up! 🎉'), findsOneWidget);
      expect(
        find.textContaining('Zero pending expenses in this approvals queue'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('empty_reset_queue_button')), findsOneWidget);

      // Tap reset queue
      await tester.tap(find.byKey(const Key('empty_reset_queue_button')));
      await tester.pumpAndSettle();

      // Items restored
      expect(find.text('David Kim'), findsOneWidget);
    });

    testWidgets('tapping an approval card navigates to TransactionDetailScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Skip onboarding to land on HomeScreen
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Tap Approvals bento button on HomeScreen
      await tester.ensureVisible(find.byKey(const Key('bento_approvals')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bento_approvals')));
      await tester.pumpAndSettle();

      expect(find.text('Alex Johnson'), findsOneWidget);

      // Tap Alex Johnson's approval card
      await tester.tap(find.byKey(const Key('approval_card_appr-01')));
      await tester.pumpAndSettle();

      // Verify TransactionDetailScreen opened
      expect(find.text('Transaction Detail'), findsOneWidget);
    });
  });
}
