import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/models/expense.dart';
import 'package:expense_guard/core/repositories/repositories.dart';

void main() {
  group('ExpensesRepository Unit Tests', () {
    late ExpensesRepository repository;

    setUp(() {
      repository = ExpensesRepository();
    });

    test('getExpenses loads default corporate expenses (Delta, AWS, Uber, Apple)', () async {
      final expenses = await repository.getExpenses();

      expect(expenses.length, 5);
      expect(expenses.any((e) => e.merchant == 'Delta Air Lines'), isTrue);
      expect(expenses.any((e) => e.merchant == 'Amazon Web Services'), isTrue);
      expect(expenses.any((e) => e.merchant == 'Uber Technologies'), isTrue);
      expect(expenses.any((e) => e.merchant == 'Apple Store'), isTrue);
      expect(expenses.any((e) => e.merchant == 'Starbucks Coffee'), isTrue);
    });

    test('getExpenses filters by category, status, and search query', () async {
      // 1. Filter by category
      final travelExpenses = await repository.getExpenses(category: 'Travel');
      expect(travelExpenses.length, 1);
      expect(travelExpenses.first.merchant, 'Delta Air Lines');

      // 2. Filter by status
      final pendingExpenses =
          await repository.getExpenses(status: ExpenseStatus.pending);
      expect(pendingExpenses.length, 2); // AWS and Apple Store

      // 3. Filter by search query
      final uberExpenses = await repository.getExpenses(searchQuery: 'Uber');
      expect(uberExpenses.length, 1);
      expect(uberExpenses.first.merchant, 'Uber Technologies');
    });

    test('getExpenseById returns matching expense or null for invalid ID', () async {
      final delta = await repository.getExpenseById('exp-101');
      expect(delta, isNotNull);
      expect(delta!.merchant, 'Delta Air Lines');
      expect(delta.amount, 845.00);
      expect(delta.lineItems.length, 2);

      final nonexistent = await repository.getExpenseById('invalid-id');
      expect(nonexistent, isNull);
    });

    test('createExpense, updateExpense, and deleteExpense work correctly', () async {
      final newExpense = Expense(
        id: 'exp-999',
        merchant: 'Google Cloud Platform',
        amount: 210.00,
        category: 'Software',
        date: DateTime.now(),
      );

      // Create
      await repository.createExpense(newExpense);
      var fetched = await repository.getExpenseById('exp-999');
      expect(fetched, isNotNull);
      expect(fetched!.merchant, 'Google Cloud Platform');

      // Update
      final updated = fetched.copyWith(amount: 250.00);
      await repository.updateExpense(updated);
      fetched = await repository.getExpenseById('exp-999');
      expect(fetched!.amount, 250.00);

      // Delete
      final deleted = await repository.deleteExpense('exp-999');
      expect(deleted, isTrue);
      fetched = await repository.getExpenseById('exp-999');
      expect(fetched, isNull);
    });

    test('approveExpense and rejectExpense mutate workflow status', () async {
      // Approve AWS
      final approvedAws = await repository.approveExpense('exp-102');
      expect(approvedAws.status, ExpenseStatus.approved);
      expect(approvedAws.policyCompliant, isTrue);

      // Reject Apple Store
      final rejectedApple = await repository.rejectExpense(
        'exp-104',
        reason: 'Unauthorized peripheral purchase',
      );
      expect(rejectedApple.status, ExpenseStatus.rejected);
      expect(rejectedApple.policyNote, 'Unauthorized peripheral purchase');
    });
  });

  group('CardsRepository Unit Tests', () {
    late CardsRepository repository;

    setUp(() {
      repository = CardsRepository();
    });

    test('getCards returns fleet with physical and virtual corporate cards', () async {
      final cards = await repository.getCards();

      expect(cards.length, 3);
      expect(cards[0].last4, '4289'); // Physical Visa
      expect(cards[0].isVirtual, isFalse);
      expect(cards[0].monthlyLimit, 5000.0);

      expect(cards[1].last4, '9912'); // Virtual Subscriptions (Frozen)
      expect(cards[1].isVirtual, isTrue);
      expect(cards[1].isFrozen, isTrue);

      expect(cards[2].last4, '3310'); // Virtual Travel Stipend
      expect(cards[2].isVirtual, isTrue);
      expect(cards[2].isFrozen, isFalse);
    });

    test('setFreezeStatus locks and unlocks cards', () async {
      // Unfreeze card-02
      final unfrozen = await repository.setFreezeStatus('card-02', false);
      expect(unfrozen.isFrozen, isFalse);

      // Freeze card-01
      final frozen = await repository.setFreezeStatus('card-01', true);
      expect(frozen.isFrozen, isTrue);
    });

    test('updateMonthlyLimit updates card limit', () async {
      final updated = await repository.updateMonthlyLimit('card-01', 7500.0);
      expect(updated.monthlyLimit, 7500.0);
    });

    test('requestNewCard provisions a new card', () async {
      final newCard = await repository.requestNewCard(
        cardholderName: 'Alex Johnson',
        isVirtual: true,
        monthlyLimit: 3000.0,
        cardLabel: 'DevOps Cloud Spend',
      );

      expect(newCard.id, 'card-04');
      expect(newCard.isVirtual, isTrue);
      expect(newCard.monthlyLimit, 3000.0);
      expect(newCard.cardLabel, 'DevOps Cloud Spend');

      final fleet = await repository.getCards();
      expect(fleet.length, 4);
    });
  });

  group('NotificationsRepository Unit Tests', () {
    late NotificationsRepository repository;

    setUp(() {
      repository = NotificationsRepository();
    });

    test('getNotifications and getUnreadCount return corporate notices', () async {
      final notifs = await repository.getNotifications();
      expect(notifs.length, 6);

      final unreadCount = await repository.getUnreadCount();
      expect(unreadCount, 3); // notif-01, notif-02, notif-05
    });

    test('markAsRead and markAllAsRead update read states', () async {
      await repository.markAsRead('notif-01');
      var unreadCount = await repository.getUnreadCount();
      expect(unreadCount, 2);

      await repository.markAllAsRead();
      unreadCount = await repository.getUnreadCount();
      expect(unreadCount, 0);
    });

    test('deleteNotification removes targeted item', () async {
      final deleted = await repository.deleteNotification('notif-01');
      expect(deleted, isTrue);

      final remaining = await repository.getNotifications();
      expect(remaining.length, 5);
      expect(remaining.any((n) => n.id == 'notif-01'), isFalse);
    });
  });

  group('Riverpod FutureProviders & Dependency Injection Tests', () {
    test('FutureProviders resolve async data through repositories', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. expensesFutureProvider
      final expenses = await container.read(expensesFutureProvider.future);
      expect(expenses.length, 5);
      expect(expenses.first.merchant, 'Delta Air Lines');

      // 2. expenseDetailFutureProvider
      final detail = await container.read(expenseDetailFutureProvider('exp-101').future);
      expect(detail, isNotNull);
      expect(detail!.merchant, 'Delta Air Lines');

      // 3. corporateCardsFutureProvider
      final cards = await container.read(corporateCardsFutureProvider.future);
      expect(cards.length, 3);
      expect(cards.first.last4, '4289');

      // 4. notificationsFutureProvider
      final notifications =
          await container.read(notificationsFutureProvider.future);
      expect(notifications.length, 6);

      // 5. unreadNotificationsCountFutureProvider
      final unreadCount =
          await container.read(unreadNotificationsCountFutureProvider.future);
      expect(unreadCount, 3);
    });

    test('Dependency Injection allows repository overrides in test scope', () async {
      final customExpense = Expense(
        id: 'mock-01',
        merchant: 'Mocked Corporate Vendor',
        amount: 99.99,
        category: 'Testing',
        date: DateTime.now(),
      );

      final mockRepo = ExpensesRepository(initialData: [customExpense]);

      final container = ProviderContainer(
        overrides: [
          expensesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final expenses = await container.read(expensesFutureProvider.future);
      expect(expenses.length, 1);
      expect(expenses.first.merchant, 'Mocked Corporate Vendor');
      expect(expenses.first.amount, 99.99);
    });
  });
}
