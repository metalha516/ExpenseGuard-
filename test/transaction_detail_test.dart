import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_guard/main.dart';
import 'package:expense_guard/features/expenses/presentation/transaction_detail_screen.dart';
import 'package:expense_guard/features/expenses/providers/transaction_details_provider.dart';
import 'package:expense_guard/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({String? transactionId}) {
    return ProviderScope(
      child: MaterialApp(
        home: TransactionDetailScreen(transactionId: transactionId),
      ),
    );
  }

  group('TransactionDetails Provider Unit Tests', () {
    test('resolves default Stitch Blue Bottle Coffee details when id is default or empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final details = container.read(
        transactionDetailsProvider(TransactionDetailScreen.defaultScreenId),
      );

      expect(details.transaction.merchant, 'Blue Bottle Coffee');
      expect(details.transaction.amount, 12.50);
      expect(details.transaction.category, 'Food & Beverage');
      expect(details.transaction.status, TransactionStatus.autoCleared);
      expect(details.lineItems.length, 3);
      expect(details.policyChecks.length, 3);
      expect(details.policyViolationBadges, isEmpty);
      expect(details.mapSnippet, isNotNull);
      expect(details.mapSnippet!.locationName, contains('Hayes Valley'));
      expect(details.timeline.length, 4);
    });

    test('resolves AWS SaaS transaction without map snippet and with itemized cloud items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final details = container.read(transactionDetailsProvider('txn-103'));

      expect(details.transaction.merchant, 'AWS Cloud Services');
      expect(details.transaction.amount, 124.50);
      expect(details.mapSnippet, isNull);
      expect(details.lineItems.any((i) => i.description.contains('EC2')), isTrue);
    });

    test('resolves Apple Store transaction with policy violation badges', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final details = container.read(transactionDetailsProvider('txn-105'));

      expect(details.transaction.merchant, 'Apple Store');
      expect(details.transaction.status, TransactionStatus.flagged);
      expect(details.policyViolationBadges, contains('Missing Receipt'));
      expect(details.policyViolationBadges, contains('Pre-approval Required'));
      expect(details.timeline.any((t) => t.isRejected), isTrue);
    });

    test('markAsCleared notifier mutation clears policy violations and updates status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(transactionDetailsNotifierProvider('txn-105').notifier);

      expect(
        container.read(transactionDetailsProvider('txn-105')).policyViolationBadges,
        isNotEmpty,
      );

      notifier.markAsCleared();

      final updated = container.read(transactionDetailsProvider('txn-105'));
      expect(updated.transaction.status, TransactionStatus.autoCleared);
      expect(updated.policyViolationBadges, isEmpty);
      expect(updated.policyExplanation, contains('Manually cleared'));
    });
  });

  group('TransactionDetailScreen Widget Tests', () {
    testWidgets('renders Stitch default Blue Bottle Coffee layout and details',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Top App Bar & Back Button
      expect(find.text('Transaction Detail'), findsOneWidget);
      expect(find.byKey(const Key('transaction_detail_back_button')), findsOneWidget);
      expect(find.byKey(const Key('transaction_detail_share_button')), findsOneWidget);

      // 2. Status Pill (Auto-cleared)
      expect(find.byKey(const Key('status_pill')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('status_pill')),
          matching: find.text('Auto-cleared'),
        ),
        findsOneWidget,
      );

      // 3. Receipt thumbnail & zoom button
      expect(find.byKey(const Key('receipt_thumbnail_container')), findsOneWidget);
      expect(find.byKey(const Key('receipt_zoom_button')), findsOneWidget);

      // 4. Transaction Summary Card
      expect(find.byKey(const Key('transaction_summary_card')), findsOneWidget);
      expect(find.text('Blue Bottle Coffee'), findsOneWidget);
      expect(find.text('\$12.50'), findsWidgets);
      expect(find.text('Food & Beverage'), findsOneWidget);
      expect(find.text('Alex Chen'), findsOneWidget);

      // 5. Map Snippet
      expect(find.byKey(const Key('map_snippet_card')), findsOneWidget);
      expect(find.text('Merchant Location'), findsOneWidget);
      expect(find.text('Blue Bottle Coffee • Hayes Valley'), findsOneWidget);
      expect(find.text('315 Linden St, San Francisco, CA 94102'), findsOneWidget);

      // 6. Itemized Line Items Breakdown
      await tester.ensureVisible(find.byKey(const Key('line_items_section')));
      expect(find.byKey(const Key('line_items_section')), findsOneWidget);
      expect(find.text('Itemized Breakdown'), findsOneWidget);
      expect(find.text('Single Origin Espresso (Hayes Valley)'), findsOneWidget);
      expect(find.text('Oat Milk Gibraltar'), findsOneWidget);
      expect(find.text('Organic Morning Croissant'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);

      // 7. Policy Check Bento
      await tester.ensureVisible(find.byKey(const Key('policy_check_section')));
      expect(find.byKey(const Key('policy_check_section')), findsOneWidget);
      expect(find.text('Policy Check'), findsOneWidget);
      expect(find.text('Receipt detected'), findsOneWidget);
      expect(find.text('Under \$50 threshold'), findsOneWidget);
      expect(find.text('Approved vendor'), findsOneWidget);
      expect(
        find.textContaining("matches your team's travel policy"),
        findsOneWidget,
      );

      // 8. Approval Workflow Timeline
      await tester.ensureVisible(find.byKey(const Key('approval_timeline_section')));
      expect(find.byKey(const Key('approval_timeline_section')), findsOneWidget);
      expect(find.text('Approval Workflow'), findsOneWidget);
      expect(find.text('Card Swiped'), findsOneWidget);
      expect(find.text('Receipt Captured'), findsOneWidget);
      expect(find.text('Policy Evaluated'), findsOneWidget);

      // 9. Done button
      await tester.ensureVisible(find.byKey(const Key('transaction_detail_dismiss_button')));
      expect(find.byKey(const Key('transaction_detail_dismiss_button')), findsOneWidget);
    });

    testWidgets('omits map snippet for online software subscription (AWS Cloud Services)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(transactionId: 'txn-103'));
      await tester.pumpAndSettle();

      expect(find.text('AWS Cloud Services'), findsOneWidget);
      expect(find.text('\$124.50'), findsWidgets);
      // Map snippet must not be rendered for SaaS transactions
      expect(find.byKey(const Key('map_snippet_card')), findsNothing);

      // Itemized cloud line items must be visible
      expect(find.textContaining('Amazon Elastic Compute Cloud (EC2)'), findsOneWidget);
    });

    testWidgets('displays policy violation badges and handles resolution for Apple Store (txn-105)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(transactionId: 'txn-105'));
      await tester.pumpAndSettle();

      // Policy Flag badge in pill
      expect(find.text('Policy Flag'), findsOneWidget);

      // Violation Badges
      expect(find.text('Missing Receipt'), findsOneWidget);
      expect(find.text('Pre-approval Required'), findsOneWidget);

      // Resolve button
      final resolveBtn = find.byKey(const Key('resolve_violation_button'));
      expect(resolveBtn, findsOneWidget);

      // Tap resolve button
      await tester.ensureVisible(resolveBtn);
      await tester.pumpAndSettle();
      await tester.tap(resolveBtn);
      await tester.pumpAndSettle();

      // Should now update to Auto-cleared and hide violation button
      expect(find.text('Auto-cleared'), findsOneWidget);
      expect(find.byKey(const Key('resolve_violation_button')), findsNothing);
    });

    testWidgets('tapping receipt zoom button opens InteractiveViewer zoom dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap zoom button
      final zoomBtn = find.byKey(const Key('receipt_zoom_button'));
      await tester.ensureVisible(zoomBtn);
      await tester.pumpAndSettle();
      await tester.tap(zoomBtn);
      await tester.pumpAndSettle();

      // Verify zoom dialog opened
      expect(find.text('Receipt Inspection'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byKey(const Key('receipt_zoom_close_button')), findsOneWidget);

      // Close dialog
      await tester.tap(find.byKey(const Key('receipt_zoom_close_button')));
      await tester.pumpAndSettle();

      expect(find.text('Receipt Inspection'), findsNothing);
    });

    testWidgets('integration: routes to TransactionDetailScreen from GoRouter',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Skip onboarding to land on HomeScreen
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Tap Starbucks in recent transactions
      await tester.ensureVisible(find.text('Starbucks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Starbucks'));
      await tester.pumpAndSettle();

      // Verify navigation into TransactionDetailScreen
      expect(find.text('Transaction Detail'), findsOneWidget);
      expect(find.text('Starbucks'), findsOneWidget);
      expect(find.text('\$6.75'), findsWidgets);
      expect(find.text('Meals & Dining'), findsOneWidget);
      expect(find.byKey(const Key('map_snippet_card')), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const Key('transaction_detail_back_button')));
      await tester.pumpAndSettle();

      // Back on HomeScreen
      expect(find.text('Good morning, Alex'), findsOneWidget);
    });
  });
}
