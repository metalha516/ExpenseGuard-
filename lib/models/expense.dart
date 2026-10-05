import 'package:flutter/foundation.dart';

/// Status of an expense in the approval & policy checking workflow.
enum ExpenseStatus {
  pending,
  reviewing,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ExpenseStatus.pending:
        return 'Pending';
      case ExpenseStatus.reviewing:
        return 'Reviewing';
      case ExpenseStatus.approved:
        return 'Approved';
      case ExpenseStatus.rejected:
        return 'Rejected';
    }
  }

  static ExpenseStatus fromString(String value) {
    return ExpenseStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ExpenseStatus.pending,
    );
  }
}

/// An individual line item parsed from a receipt.
@immutable
class ExpenseLineItem {
  const ExpenseLineItem({
    required this.description,
    required this.amount,
    this.quantity = 1,
  });

  final String description;
  final double amount;
  final int quantity;

  ExpenseLineItem copyWith({
    String? description,
    double? amount,
    int? quantity,
  }) {
    return ExpenseLineItem(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'quantity': quantity,
    };
  }

  factory ExpenseLineItem.fromJson(Map<String, dynamic> json) {
    return ExpenseLineItem(
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseLineItem &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          amount == other.amount &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(description, amount, quantity);

  @override
  String toString() =>
      'ExpenseLineItem(description: $description, amount: $amount, quantity: $quantity)';
}

/// Foundational Expense domain model with policy compliance and receipt details.
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.merchant,
    required this.amount,
    this.currency = 'USD',
    required this.category,
    required this.date,
    this.receiptUrl,
    this.status = ExpenseStatus.pending,
    this.policyCompliant = true,
    this.policyNote,
    this.notes,
    this.cardId,
    this.lineItems = const [],
    this.createdAt,
  });

  final String id;
  final String merchant;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String? receiptUrl;
  final ExpenseStatus status;
  final bool policyCompliant;
  final String? policyNote;
  final String? notes;
  final String? cardId;
  final List<ExpenseLineItem> lineItems;
  final DateTime? createdAt;

  Expense copyWith({
    String? id,
    String? merchant,
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    String? receiptUrl,
    ExpenseStatus? status,
    bool? policyCompliant,
    String? policyNote,
    String? notes,
    String? cardId,
    List<ExpenseLineItem>? lineItems,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      status: status ?? this.status,
      policyCompliant: policyCompliant ?? this.policyCompliant,
      policyNote: policyNote ?? this.policyNote,
      notes: notes ?? this.notes,
      cardId: cardId ?? this.cardId,
      lineItems: lineItems ?? this.lineItems,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'status': status.name,
      'policyCompliant': policyCompliant,
      'policyNote': policyNote,
      'notes': notes,
      'cardId': cardId,
      'lineItems': lineItems.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? '',
      merchant: json['merchant'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      category: json['category'] as String? ?? 'General',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      receiptUrl: json['receiptUrl'] as String?,
      status: json['status'] != null
          ? ExpenseStatus.fromString(json['status'] as String)
          : ExpenseStatus.pending,
      policyCompliant: json['policyCompliant'] as bool? ?? true,
      policyNote: json['policyNote'] as String?,
      notes: json['notes'] as String?,
      cardId: json['cardId'] as String?,
      lineItems: (json['lineItems'] as List<dynamic>?)
              ?.map((e) => ExpenseLineItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          merchant == other.merchant &&
          amount == other.amount &&
          currency == other.currency &&
          category == other.category &&
          date == other.date &&
          receiptUrl == other.receiptUrl &&
          status == other.status &&
          policyCompliant == other.policyCompliant &&
          policyNote == other.policyNote &&
          notes == other.notes &&
          cardId == other.cardId &&
          listEquals(lineItems, other.lineItems);

  @override
  int get hashCode => Object.hash(
        id,
        merchant,
        amount,
        currency,
        category,
        date,
        receiptUrl,
        status,
        policyCompliant,
        policyNote,
        notes,
        cardId,
      );

  @override
  String toString() =>
      'Expense(id: $id, merchant: $merchant, amount: $amount, status: ${status.name})';
}
