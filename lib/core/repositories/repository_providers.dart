import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/models/expense.dart';
import 'package:expense_guard/models/corporate_card.dart';
import 'package:expense_guard/models/notification_item.dart';
import 'package:expense_guard/core/repositories/expenses_repository.dart';
import 'package:expense_guard/core/repositories/cards_repository.dart';
import 'package:expense_guard/core/repositories/notifications_repository.dart';

// ============================================================================
// 1. Dependency Injection Repository Providers
// ============================================================================

/// Dependency injection provider for [ExpensesRepository].
final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository();
});

/// Dependency injection provider for [CardsRepository].
final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  return CardsRepository();
});

/// Dependency injection provider for [NotificationsRepository].
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

// ============================================================================
// 2. FutureProviders for Asynchronous Data & State Handling
// ============================================================================

/// FutureProvider supplying the complete corporate expenses list.
final expensesFutureProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getExpenses();
});

/// FutureProvider family supplying single expense by its ID.
final expenseDetailFutureProvider =
    FutureProvider.family<Expense?, String>((ref, id) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getExpenseById(id);
});

/// FutureProvider supplying corporate cards fleet.
final corporateCardsFutureProvider =
    FutureProvider<List<CorporateCard>>((ref) async {
  final repository = ref.watch(cardsRepositoryProvider);
  return repository.getCards();
});

/// FutureProvider supplying single corporate card by ID.
final cardDetailFutureProvider =
    FutureProvider.family<CorporateCard?, String>((ref, id) async {
  final repository = ref.watch(cardsRepositoryProvider);
  return repository.getCardById(id);
});

/// FutureProvider supplying all notification items.
final notificationsFutureProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.getNotifications();
});

/// FutureProvider supplying unread notifications count for badges.
final unreadNotificationsCountFutureProvider =
    FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.getUnreadCount();
});
