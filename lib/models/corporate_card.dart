import 'package:flutter/foundation.dart';

/// Foundational CorporateCard domain model with budget limits and freeze controls.
@immutable
class CorporateCard {
  const CorporateCard({
    required this.id,
    required this.cardholderName,
    required this.last4,
    this.brand = 'Visa',
    required this.expiryMonth,
    required this.expiryYear,
    required this.monthlyLimit,
    this.currentSpend = 0.0,
    this.currency = 'USD',
    this.isVirtual = true,
    this.isFrozen = false,
    this.cardColorHex = '#B5EAD7',
    this.cardLabel,
  });

  final String id;
  final String cardholderName;
  final String last4;
  final String brand;
  final int expiryMonth;
  final int expiryYear;
  final double monthlyLimit;
  final double currentSpend;
  final String currency;
  final bool isVirtual;
  final bool isFrozen;
  final String cardColorHex;
  final String? cardLabel;

  /// Display name of the card (e.g. Corporate Visa or Software Subs)
  String get displayName =>
      cardLabel ?? (isVirtual ? 'Software Subs (Virtual)' : 'Corporate Visa');

  /// Remaining spend available on card
  double get remainingLimit => (monthlyLimit - currentSpend).clamp(0.0, double.infinity);

  /// Card utilization percentage (0.0 to 100.0)
  double get utilizationPercent =>
      monthlyLimit > 0 ? ((currentSpend / monthlyLimit) * 100).clamp(0.0, 100.0) : 0.0;

  /// Formatted expiry string (e.g. 12/28)
  String get formattedExpiry =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(expiryYear.toString().length - 2)}';

  CorporateCard copyWith({
    String? id,
    String? cardholderName,
    String? last4,
    String? brand,
    int? expiryMonth,
    int? expiryYear,
    double? monthlyLimit,
    double? currentSpend,
    String? currency,
    bool? isVirtual,
    bool? isFrozen,
    String? cardColorHex,
    String? cardLabel,
  }) {
    return CorporateCard(
      id: id ?? this.id,
      cardholderName: cardholderName ?? this.cardholderName,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currentSpend: currentSpend ?? this.currentSpend,
      currency: currency ?? this.currency,
      isVirtual: isVirtual ?? this.isVirtual,
      isFrozen: isFrozen ?? this.isFrozen,
      cardColorHex: cardColorHex ?? this.cardColorHex,
      cardLabel: cardLabel ?? this.cardLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardholderName': cardholderName,
      'last4': last4,
      'brand': brand,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'monthlyLimit': monthlyLimit,
      'currentSpend': currentSpend,
      'currency': currency,
      'isVirtual': isVirtual,
      'isFrozen': isFrozen,
      'cardColorHex': cardColorHex,
      'cardLabel': cardLabel,
    };
  }

  factory CorporateCard.fromJson(Map<String, dynamic> json) {
    return CorporateCard(
      id: json['id'] as String? ?? '',
      cardholderName: json['cardholderName'] as String? ?? '',
      last4: json['last4'] as String? ?? '4291',
      brand: json['brand'] as String? ?? 'Visa',
      expiryMonth: (json['expiryMonth'] as num?)?.toInt() ?? 12,
      expiryYear: (json['expiryYear'] as num?)?.toInt() ?? 2028,
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 5000.0,
      currentSpend: (json['currentSpend'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      isVirtual: json['isVirtual'] as bool? ?? true,
      isFrozen: json['isFrozen'] as bool? ?? false,
      cardColorHex: json['cardColorHex'] as String? ?? '#B5EAD7',
      cardLabel: json['cardLabel'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CorporateCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cardholderName == other.cardholderName &&
          last4 == other.last4 &&
          brand == other.brand &&
          expiryMonth == other.expiryMonth &&
          expiryYear == other.expiryYear &&
          monthlyLimit == other.monthlyLimit &&
          currentSpend == other.currentSpend &&
          currency == other.currency &&
          isVirtual == other.isVirtual &&
          isFrozen == other.isFrozen &&
          cardColorHex == other.cardColorHex &&
          cardLabel == other.cardLabel;

  @override
  int get hashCode => Object.hash(
        id,
        cardholderName,
        last4,
        brand,
        expiryMonth,
        expiryYear,
        monthlyLimit,
        currentSpend,
        currency,
        isVirtual,
        isFrozen,
        cardColorHex,
        cardLabel,
      );

  @override
  String toString() =>
      'CorporateCard(id: $id, label: $displayName, last4: $last4, limit: $monthlyLimit, spend: $currentSpend, frozen: $isFrozen)';
}
