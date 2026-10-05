import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/expenses/presentation/expense_review_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget({
    String? imagePath,
    bool autoScan = true,
  }) {
    final router = GoRouter(
      initialLocation: '/expense-review',
      routes: [
        GoRoute(
          path: '/expense-review',
          builder: (context, state) => ExpenseReviewScreen(
            imagePath: imagePath,
            autoScan: autoScan,
          ),
        ),
        GoRoute(
          path: '/policy-check',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Policy Check Screen Destination')),
          ),
        ),
      ],
    );

    return ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }

  group('ExpenseReviewScreen Widget Tests', () {
    testWidgets(
        'Renders initial scanning state with scanning badge and disabled submit button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          imagePath: '/mock/test_receipt.jpg',
          autoScan: false, // Don't auto-fill, simulate initial scanning state
        ),
      );
      await tester.pump();

      // Verify Screen Header
      expect(find.text('Expense Review'), findsOneWidget);
      expect(find.text('Review & Edit Details'), findsOneWidget);

      // Verify Receipt Thumbnail and badge
      expect(find.byKey(const Key('receipt_thumbnail_container')), findsOneWidget);
      expect(find.byKey(const Key('receipt_status_badge')), findsOneWidget);

      // Verify amount display hero
      expect(find.byKey(const Key('expense_amount_display')), findsOneWidget);

      // Verify Form inputs
      expect(find.byKey(const Key('expense_vendor_input')), findsOneWidget);
      expect(find.byKey(const Key('expense_category_selector')), findsOneWidget);
      expect(find.byKey(const Key('expense_date_selector')), findsOneWidget);
      expect(find.byKey(const Key('expense_amount_input')), findsOneWidget);

      // Submit button should be disabled when empty/invalid
      final submitButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('expense_submit_button')),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets(
        'Simulated OCR completes and auto-fills Vendor, Amount, Date, and Category',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          imagePath: '/mock/receipts/aws_october_invoice.jpg',
          autoScan: true,
        ),
      );
      await tester.pumpAndSettle();

      // Verify OCR extracted badge
      expect(find.byKey(const Key('receipt_status_badge')), findsOneWidget);
      expect(find.text('Extracted'), findsOneWidget);

      // Verify Auto-filled Vendor
      final vendorFinder = find.byKey(const Key('expense_vendor_input'));
      expect(vendorFinder, findsOneWidget);
      final vendorField = tester.widget<TextFormField>(vendorFinder);
      expect(vendorField.controller?.text, 'AWS');

      // Verify Auto-filled Hero Amount & Amount input
      expect(find.text('\$49.99'), findsWidgets);

      // Verify Auto-filled Category
      expect(find.text('Software Subscription'), findsOneWidget);

      // Verify Policy Card
      expect(find.byKey(const Key('expense_policy_card')), findsOneWidget);
      expect(find.text("This one's all set ✅"), findsOneWidget);
      expect(find.text('Within monthly software budget'), findsOneWidget);

      // Verify Submit button is now enabled
      final submitButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('expense_submit_button')),
      );
      expect(submitButton.onPressed, isNotNull);
    });

    testWidgets(
        'Editing amount dynamically updates policy compliance check card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          imagePath: '/mock/receipt.jpg',
          autoScan: true,
        ),
      );
      await tester.pumpAndSettle();

      // Initially compliant
      expect(find.text("This one's all set ✅"), findsOneWidget);

      // Enter amount exceeding threshold: $300.00
      final amountInput = find.byKey(const Key('expense_amount_input'));
      await tester.ensureVisible(amountInput);
      await tester.pumpAndSettle();
      await tester.enterText(amountInput, '300.00');
      await tester.pumpAndSettle();

      // Verify policy card warns about manager approval
      expect(find.text('Manager Approval Required ⚠️'), findsOneWidget);
      expect(
        find.text('Software subscription exceeds \$200.00 pre-approval threshold'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Selecting Category opens bottom sheet and updates selected category',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          imagePath: '/mock/receipt.jpg',
          autoScan: true,
        ),
      );
      await tester.pumpAndSettle();

      // Scroll and Tap Category Selector
      await tester.ensureVisible(find.byKey(const Key('expense_category_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('expense_category_selector')));
      await tester.pumpAndSettle();

      // Verify Bottom sheet opened
      expect(find.text('Select Expense Category'), findsOneWidget);
      expect(find.text('Meals & Entertainment'), findsOneWidget);
      expect(find.text('Travel & Lodging'), findsOneWidget);

      // Select Travel & Lodging
      await tester.tap(find.byKey(const Key('category_item_Travel & Lodging')));
      await tester.pumpAndSettle();

      // Verify bottom sheet dismissed and category updated
      expect(find.text('Select Expense Category'), findsNothing);
      expect(find.text('Travel & Lodging'), findsOneWidget);
    });

    testWidgets(
        'Tapping Submit button navigates to /policy-check with expense object',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          imagePath: '/mock/receipts/valid_aws_receipt.jpg',
          autoScan: true,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Submit Button
      await tester.tap(find.byKey(const Key('expense_submit_button')));
      await tester.pumpAndSettle();

      // Verify navigation to destination
      expect(find.text('Policy Check Screen Destination'), findsOneWidget);
    });
  });
}
