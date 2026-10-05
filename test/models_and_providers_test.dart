import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_guard/models/models.dart';
import 'package:expense_guard/features/shared/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Expense Model Tests', () {
    test('Expense JSON serialization and deserialization works correctly', () {
      final now = DateTime(2026, 10, 5, 12, 0);
      final expense = Expense(
        id: 'exp-101',
        merchant: 'Starbucks',
        amount: 14.50,
        currency: 'USD',
        category: 'Meals & Dining',
        date: now,
        status: ExpenseStatus.approved,
        policyCompliant: true,
        policyNote: 'Under per-diem breakfast allowance',
        lineItems: const [
          ExpenseLineItem(description: 'Latte', amount: 6.50),
          ExpenseLineItem(description: 'Croissant', amount: 8.00),
        ],
      );

      final json = expense.toJson();
      expect(json['id'], 'exp-101');
      expect(json['merchant'], 'Starbucks');
      expect(json['amount'], 14.50);
      expect(json['status'], 'approved');
      expect((json['lineItems'] as List).length, 2);

      final decoded = Expense.fromJson(json);
      expect(decoded.id, expense.id);
      expect(decoded.merchant, expense.merchant);
      expect(decoded.amount, expense.amount);
      expect(decoded.status, ExpenseStatus.approved);
      expect(decoded.lineItems.length, 2);
      expect(decoded.lineItems.first.description, 'Latte');
      expect(decoded, expense);
    });

    test('Expense copyWith creates updated instance', () {
      final expense = Expense(
        id: 'exp-1',
        merchant: 'Uber',
        amount: 25.0,
        category: 'Transportation',
        date: DateTime.now(),
      );

      final updated = expense.copyWith(
        amount: 32.50,
        status: ExpenseStatus.reviewing,
      );

      expect(updated.id, 'exp-1');
      expect(updated.merchant, 'Uber');
      expect(updated.amount, 32.50);
      expect(updated.status, ExpenseStatus.reviewing);
      expect(expense.amount, 25.0);
    });
  });

  group('Transaction Model Tests', () {
    test('Transaction JSON serialization and deserialization', () {
      final now = DateTime(2026, 10, 4, 15, 30);
      final txn = Transaction(
        id: 'txn-501',
        merchant: 'AWS Cloud Services',
        amount: 124.50,
        category: 'Software & Cloud',
        timestamp: now,
        status: TransactionStatus.autoCleared,
        cardLast4: '4291',
        iconName: 'cloud',
        receiptAttached: true,
      );

      final json = txn.toJson();
      expect(json['id'], 'txn-501');
      expect(json['merchant'], 'AWS Cloud Services');
      expect(json['status'], 'autoCleared');

      final decoded = Transaction.fromJson(json);
      expect(decoded.id, txn.id);
      expect(decoded.status, TransactionStatus.autoCleared);
      expect(decoded.receiptAttached, true);
      expect(decoded, txn);
    });

    test('Transaction copyWith updates fields properly', () {
      final txn = Transaction(
        id: 'txn-1',
        merchant: 'Delta',
        amount: 450.0,
        category: 'Travel',
        timestamp: DateTime.now(),
      );

      final updated = txn.copyWith(status: TransactionStatus.flagged);
      expect(updated.status, TransactionStatus.flagged);
      expect(txn.status, TransactionStatus.cleared);
    });
  });

  group('CorporateCard Model Tests', () {
    test('CorporateCard calculates limits, utilization and expiry properly', () {
      const card = CorporateCard(
        id: 'card-1',
        cardholderName: 'Alex Morgan',
        last4: '4291',
        brand: 'Visa',
        expiryMonth: 8,
        expiryYear: 2028,
        monthlyLimit: 5000.0,
        currentSpend: 1500.0,
      );

      expect(card.remainingLimit, 3500.0);
      expect(card.utilizationPercent, 30.0);
      expect(card.formattedExpiry, '08/28');

      final json = card.toJson();
      expect(json['last4'], '4291');
      expect(json['monthlyLimit'], 5000.0);

      final decoded = CorporateCard.fromJson(json);
      expect(decoded.id, card.id);
      expect(decoded.remainingLimit, 3500.0);
      expect(decoded, card);
    });

    test('CorporateCard handles freeze and limit updates via copyWith', () {
      const card = CorporateCard(
        id: 'card-2',
        cardholderName: 'Sarah Jenkins',
        last4: '8812',
        expiryMonth: 12,
        expiryYear: 2029,
        monthlyLimit: 2000.0,
      );

      final frozenCard = card.copyWith(isFrozen: true, currentSpend: 2000.0);
      expect(frozenCard.isFrozen, true);
      expect(frozenCard.remainingLimit, 0.0);
      expect(frozenCard.utilizationPercent, 100.0);
      expect(card.isFrozen, false);
    });
  });

  group('NotificationItem Model Tests', () {
    test('NotificationItem JSON serialization and deserialization', () {
      final now = DateTime(2026, 10, 5, 9, 0);
      final item = NotificationItem(
        id: 'notif-1',
        title: 'Expense Approved',
        message: 'Your Starbucks \$14.50 submission was approved.',
        timestamp: now,
        type: NotificationType.expenseApproved,
        isRead: false,
      );

      final json = item.toJson();
      expect(json['type'], 'expenseApproved');
      expect(json['isRead'], false);

      final decoded = NotificationItem.fromJson(json);
      expect(decoded.title, 'Expense Approved');
      expect(decoded.type, NotificationType.expenseApproved);
      expect(decoded.isRead, false);
      expect(decoded, item);

      final readItem = decoded.copyWith(isRead: true);
      expect(readItem.isRead, true);
    });
  });

  group('ThemeModeNotifier Tests', () {
    test('ThemeModeNotifier toggles between light and dark modes', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialMode = container.read(themeModeProvider);
      expect(initialMode, ThemeMode.system);

      final notifier = container.read(themeModeProvider.notifier);
      await notifier.setDark();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.light);

      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
