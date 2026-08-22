import 'package:flutter/foundation.dart';

/// Settlement and policy status of a financial transaction.
enum TransactionStatus {
  autoCleared,
  cleared,
  reviewing,
  pending,
  flagged;

  String get displayName {
    switch (this) {
      case TransactionStatus.autoCleared:
        return 'Auto-cleared';
      case TransactionStatus.cleared:
        return 'Cleared';
      case TransactionStatus.reviewing:
        return 'Reviewing';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.flagged:
        return 'Policy Flag';
    }
  }

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TransactionStatus.cleared,
    );
  }
}

/// Foundational Transaction domain model with card link and settlement status.
@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.merchant,
    required this.amount,
    this.currency = 'USD',
    required this.category,
    required this.timestamp,
    this.status = TransactionStatus.cleared,
    this.cardLast4 = '4291',
    this.iconName = 'local_cafe',
    this.receiptAttached = false,
    this.expenseId,
    this.isCredit = false,
  });

  final String id;
  final String merchant;
  final double amount;
  final String currency;
  final String category;
  final DateTime timestamp;
  final TransactionStatus status;
  final String cardLast4;
  final String iconName;
  final bool receiptAttached;
  final String? expenseId;
  final bool isCredit;

  Transaction copyWith({
    String? id,
    String? merchant,
    double? amount,
    String? currency,
    String? category,
    DateTime? timestamp,
    TransactionStatus? status,
    String? cardLast4,
    String? iconName,
    bool? receiptAttached,
    String? expenseId,
    bool? isCredit,
  }) {
    return Transaction(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      cardLast4: cardLast4 ?? this.cardLast4,
      iconName: iconName ?? this.iconName,
      receiptAttached: receiptAttached ?? this.receiptAttached,
      expenseId: expenseId ?? this.expenseId,
      isCredit: isCredit ?? this.isCredit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'currency': currency,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'cardLast4': cardLast4,
      'iconName': iconName,
      'receiptAttached': receiptAttached,
      'expenseId': expenseId,
      'isCredit': isCredit,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? '',
      merchant: json['merchant'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      category: json['category'] as String? ?? 'General',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] != null
          ? TransactionStatus.fromString(json['status'] as String)
          : TransactionStatus.cleared,
      cardLast4: json['cardLast4'] as String? ?? '4291',
      iconName: json['iconName'] as String? ?? 'receipt',
      receiptAttached: json['receiptAttached'] as bool? ?? false,
      expenseId: json['expenseId'] as String?,
      isCredit: json['isCredit'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          merchant == other.merchant &&
          amount == other.amount &&
          currency == other.currency &&
          category == other.category &&
          timestamp == other.timestamp &&
          status == other.status &&
          cardLast4 == other.cardLast4 &&
          iconName == other.iconName &&
          receiptAttached == other.receiptAttached &&
          expenseId == other.expenseId &&
          isCredit == other.isCredit;

  @override
  int get hashCode => Object.hash(
        id,
        merchant,
        amount,
        currency,
        category,
        timestamp,
        status,
        cardLast4,
        iconName,
        receiptAttached,
        expenseId,
        isCredit,
      );

  @override
  String toString() =>
      'Transaction(id: $id, merchant: $merchant, amount: $amount, status: ${status.name})';
}
