import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/models/models.dart';

/// State model for the Home Dashboard.
@immutable
class HomeState {
  const HomeState({
    required this.userName,
    required this.userRole,
    required this.totalSpent,
    required this.monthlyLimit,
    required this.approvedAmount,
    required this.pendingAmount,
    this.currency = 'USD',
    required this.recentTransactions,
    this.unreadNotificationsCount = 3,
    this.isLoading = false,
  });

  final String userName;
  final String userRole;
  final double totalSpent;
  final double monthlyLimit;
  final double approvedAmount;
  final double pendingAmount;
  final String currency;
  final List<Transaction> recentTransactions;
  final int unreadNotificationsCount;
  final bool isLoading;

  /// Remaining available monthly budget
  double get remainingBudget =>
      (monthlyLimit - totalSpent).clamp(0.0, double.infinity);

  /// Spend ratio from 0.0 to 1.0
  double get spendRatio =>
      monthlyLimit > 0 ? (totalSpent / monthlyLimit).clamp(0.0, 1.0) : 0.0;

  /// Spend percentage formatted (0% - 100%)
  int get spendPercentage => (spendRatio * 100).round();

  HomeState copyWith({
    String? userName,
    String? userRole,
    double? totalSpent,
    double? monthlyLimit,
    double? approvedAmount,
    double? pendingAmount,
    String? currency,
    List<Transaction>? recentTransactions,
    int? unreadNotificationsCount,
    bool? isLoading,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      totalSpent: totalSpent ?? this.totalSpent,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      currency: currency ?? this.currency,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      unreadNotificationsCount:
          unreadNotificationsCount ?? this.unreadNotificationsCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeState &&
          runtimeType == other.runtimeType &&
          userName == other.userName &&
          userRole == other.userRole &&
          totalSpent == other.totalSpent &&
          monthlyLimit == other.monthlyLimit &&
          approvedAmount == other.approvedAmount &&
          pendingAmount == other.pendingAmount &&
          currency == other.currency &&
          listEquals(recentTransactions, other.recentTransactions) &&
          unreadNotificationsCount == other.unreadNotificationsCount &&
          isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(
        userName,
        userRole,
        totalSpent,
        monthlyLimit,
        approvedAmount,
        pendingAmount,
        currency,
        unreadNotificationsCount,
        isLoading,
      );
}

/// Notifier providing dashboard metrics and transaction feed.
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return _createInitialMockData();
  }

  static HomeState _createInitialMockData() {
    final now = DateTime.now();

    final mockTransactions = [
      Transaction(
        id: 'txn-101',
        merchant: 'Starbucks',
        amount: 6.75,
        currency: 'USD',
        category: 'Meals & Dining',
        timestamp: now.subtract(const Duration(hours: 2)),
        status: TransactionStatus.cleared,
        cardLast4: '4291',
        iconName: 'local_cafe',
        receiptAttached: true,
      ),
      Transaction(
        id: 'txn-102',
        merchant: 'Uber Ride',
        amount: 24.50,
        currency: 'USD',
        category: 'Transportation',
        timestamp: now.subtract(const Duration(days: 1)),
        status: TransactionStatus.reviewing,
        cardLast4: '4291',
        iconName: 'directions_car',
        receiptAttached: true,
      ),
      Transaction(
        id: 'txn-103',
        merchant: 'AWS Cloud Services',
        amount: 124.50,
        currency: 'USD',
        category: 'Software & Cloud',
        timestamp: now.subtract(const Duration(days: 3)),
        status: TransactionStatus.autoCleared,
        cardLast4: '8812',
        iconName: 'cloud',
        receiptAttached: true,
      ),
      Transaction(
        id: 'txn-104',
        merchant: 'Delta Air Lines',
        amount: 450.00,
        currency: 'USD',
        category: 'Travel & Lodging',
        timestamp: now.subtract(const Duration(days: 5)),
        status: TransactionStatus.reviewing,
        cardLast4: '4291',
        iconName: 'flight',
        receiptAttached: true,
      ),
      Transaction(
        id: 'txn-105',
        merchant: 'Apple Store',
        amount: 129.00,
        currency: 'USD',
        category: 'Hardware & Tools',
        timestamp: now.subtract(const Duration(days: 7)),
        status: TransactionStatus.cleared,
        cardLast4: '4291',
        iconName: 'laptop_mac',
        receiptAttached: false,
      ),
    ];

    return HomeState(
      userName: 'Alex',
      userRole: 'Senior Product Engineer',
      totalSpent: 2450.80,
      monthlyLimit: 5000.00,
      approvedAmount: 1850.00,
      pendingAmount: 600.80,
      currency: 'USD',
      recentTransactions: mockTransactions,
      unreadNotificationsCount: 3,
    );
  }

  /// Add a newly captured transaction to the dashboard.
  void addTransaction(Transaction transaction) {
    final updatedList = [transaction, ...state.recentTransactions];
    final updatedTotal = state.totalSpent + transaction.amount;
    state = state.copyWith(
      recentTransactions: updatedList,
      totalSpent: updatedTotal,
      pendingAmount: state.pendingAmount + transaction.amount,
    );
  }

  /// Refresh dashboard data.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isLoading: false);
  }
}

/// Provider exposing the home dashboard state.
final homeStateProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
