import 'package:flutter/foundation.dart';

/// Level of risk assessed by the automated AI compliance engine.
enum ApprovalRiskLevel {
  highRisk,
  mediumRisk,
  standard;

  String get displayName {
    switch (this) {
      case ApprovalRiskLevel.highRisk:
        return 'High Risk';
      case ApprovalRiskLevel.mediumRisk:
        return 'Elevated Risk';
      case ApprovalRiskLevel.standard:
        return 'Standard Routine';
    }
  }
}

/// Status of the approval decision.
enum ApprovalStatus {
  pending,
  approved,
  rejected,
  flagged;

  String get displayName {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
      case ApprovalStatus.flagged:
        return 'Flagged';
    }
  }
}

/// Domain model representing a submitted team expense pending manager or finance sign-off.
@immutable
class ApprovalItem {
  const ApprovalItem({
    required this.id,
    required this.transactionId,
    required this.employeeName,
    required this.employeeRole,
    required this.merchant,
    required this.amount,
    required this.category,
    required this.date,
    required this.riskLevel,
    required this.fraudRiskScore,
    this.currency = 'USD',
    this.employeeAvatarUrl,
    this.policyWarning,
    this.userNote,
    this.hasReceipt = true,
    this.violationTags = const [],
    this.status = ApprovalStatus.pending,
    this.iconName = 'receipt',
  });

  final String id;
  final String transactionId;
  final String employeeName;
  final String employeeRole;
  final String? employeeAvatarUrl;
  final String merchant;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final ApprovalRiskLevel riskLevel;

  /// AI-computed fraud and anomaly risk score from 0 (pristine) to 100 (critical anomaly).
  final int fraudRiskScore;

  /// Specific policy check violation warning message (if any).
  final String? policyWarning;

  /// Justification note written by the employee.
  final String? userNote;

  final bool hasReceipt;
  final List<String> violationTags;
  final ApprovalStatus status;
  final String iconName;

  bool get isHighRisk => riskLevel == ApprovalRiskLevel.highRisk;
  bool get isPending => status == ApprovalStatus.pending;

  ApprovalItem copyWith({
    String? id,
    String? transactionId,
    String? employeeName,
    String? employeeRole,
    String? employeeAvatarUrl,
    String? merchant,
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    ApprovalRiskLevel? riskLevel,
    int? fraudRiskScore,
    String? policyWarning,
    String? userNote,
    bool? hasReceipt,
    List<String>? violationTags,
    ApprovalStatus? status,
    String? iconName,
  }) {
    return ApprovalItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      employeeName: employeeName ?? this.employeeName,
      employeeRole: employeeRole ?? this.employeeRole,
      employeeAvatarUrl: employeeAvatarUrl ?? this.employeeAvatarUrl,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      riskLevel: riskLevel ?? this.riskLevel,
      fraudRiskScore: fraudRiskScore ?? this.fraudRiskScore,
      policyWarning: policyWarning ?? this.policyWarning,
      userNote: userNote ?? this.userNote,
      hasReceipt: hasReceipt ?? this.hasReceipt,
      violationTags: violationTags ?? this.violationTags,
      status: status ?? this.status,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovalItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          transactionId == other.transactionId &&
          status == other.status &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(id, transactionId, status, amount);
}
