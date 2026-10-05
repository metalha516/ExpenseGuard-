import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/features/expenses/providers/expense_form_provider.dart';
import 'package:expense_guard/models/expense.dart';

void main() {
  group('ExpenseFormNotifier Unit Tests', () {
    test('Initial state has defaults and is not valid until filled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(expenseFormProvider);
      expect(state.isScanning, false);
      expect(state.merchant, '');
      expect(state.amount, 0.0);
      expect(state.isValid, false);
    });

    test('initializeWithReceipt triggers OCR scanning and auto-fills fields', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(expenseFormProvider.notifier);
      await notifier.initializeWithReceipt(
        imagePath: '/mock/receipts/aws_receipt.jpg',
        simulatedDelay: Duration.zero,
      );

      final state = container.read(expenseFormProvider);
      expect(state.isScanning, false);
      expect(state.imagePath, '/mock/receipts/aws_receipt.jpg');
      expect(state.merchant, 'AWS');
      expect(state.amount, 49.99);
      expect(state.category, 'Software Subscription');
      expect(state.isPolicyCompliant, true);
      expect(state.policyMessage, "This one's all set ✅");
      expect(state.policySubtext, 'Within monthly software budget');
      expect(state.lineItems.length, 1);
      expect(state.isValid, true);
    });

    test('setMerchant updates merchant and impacts isValid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(expenseFormProvider.notifier);
      notifier.setMerchant('Google Cloud');
      notifier.setAmount(120.0);

      final state = container.read(expenseFormProvider);
      expect(state.merchant, 'Google Cloud');
      expect(state.amount, 120.0);
      expect(state.isValid, true);

      notifier.setMerchant('   ');
      expect(container.read(expenseFormProvider).isValid, false);
    });

    test('setAmountFromText sanitizes currency symbols and calculates policy', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(expenseFormProvider.notifier);
      notifier.setMerchant('Slack');
      notifier.setCategory('Software Subscription');
      notifier.setAmountFromText('\$250.00');

      final state = container.read(expenseFormProvider);
      expect(state.amount, 250.0);
      expect(state.isPolicyCompliant, false);
      expect(state.policyMessage, contains('Manager Approval Required'));

      // Change category to Travel
      notifier.setCategory('Travel & Lodging');
      expect(container.read(expenseFormProvider).isPolicyCompliant, true);

      // Change category to Meals & Entertainment with $100
      notifier.setCategory('Meals & Entertainment');
      expect(container.read(expenseFormProvider).isPolicyCompliant, false);
      expect(container.read(expenseFormProvider).policyMessage,
          contains('Exceeds Per-Diem Meal Limit'));
    });

    test('toExpense creates valid Expense domain object', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(expenseFormProvider.notifier);
      await notifier.initializeWithReceipt(
        imagePath: '/mock/receipt.jpg',
        simulatedDelay: Duration.zero,
      );

      final expense = notifier.state.toExpense(id: 'test_exp_123');
      expect(expense.id, 'test_exp_123');
      expect(expense.merchant, 'AWS');
      expect(expense.amount, 49.99);
      expect(expense.category, 'Software Subscription');
      expect(expense.receiptUrl, '/mock/receipt.jpg');
      expect(expense.policyCompliant, true);
      expect(expense.status, ExpenseStatus.pending);
    });
  });
}
