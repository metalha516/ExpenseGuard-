import 'package:flutter/foundation.dart';

/// Categories of notifications in the ExpenseGuard app.
enum NotificationType {
  policyAlert,
  approvalRequest,
  expenseApproved,
  expenseRejected,
  cardLimitWarning,
  system;

  String get displayName {
    switch (this) {
      case NotificationType.policyAlert:
        return 'Policy Alert';
      case NotificationType.approvalRequest:
        return 'Approval Request';
      case NotificationType.expenseApproved:
        return 'Expense Approved';
      case NotificationType.expenseRejected:
        return 'Expense Rejected';
      case NotificationType.cardLimitWarning:
        return 'Card Limit Warning';
      case NotificationType.system:
        return 'System Notification';
    }
  }

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => NotificationType.system,
    );
  }
}

/// Foundational NotificationItem domain model.
@immutable
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = NotificationType.system,
    this.isRead = false,
    this.actionUrl,
    this.referenceId,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionUrl;
  final String? referenceId;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? actionUrl,
    String? referenceId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'actionUrl': actionUrl,
      'referenceId': referenceId,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      type: json['type'] != null
          ? NotificationType.fromString(json['type'] as String)
          : NotificationType.system,
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      referenceId: json['referenceId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          message == other.message &&
          timestamp == other.timestamp &&
          type == other.type &&
          isRead == other.isRead &&
          actionUrl == other.actionUrl &&
          referenceId == other.referenceId;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        message,
        timestamp,
        type,
        isRead,
        actionUrl,
        referenceId,
      );

  @override
  String toString() =>
      'NotificationItem(id: $id, title: $title, isRead: $isRead, type: ${type.name})';
}
