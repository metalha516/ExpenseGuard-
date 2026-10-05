import 'package:expense_guard/models/notification_item.dart';

/// Repository managing notification items, read states, and delivery.
class NotificationsRepository {
  NotificationsRepository({List<NotificationItem>? initialData})
      : _notifications = initialData ?? _buildDefaultNotifications();

  final List<NotificationItem> _notifications;

  /// Fetch all notifications with optional unread filter.
  Future<List<NotificationItem>> getNotifications({
    bool? unreadOnly,
    NotificationType? type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));

    return _notifications.where((n) {
      if (unreadOnly == true && n.isRead) {
        return false;
      }
      if (type != null && n.type != type) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get count of unread notifications.
  Future<int> getUnreadCount() async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Mark specific notification as read.
  Future<void> markAsRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  /// Delete a notification.
  Future<bool> deleteNotification(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final count = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);
    return _notifications.length < count;
  }

  /// Push/create a new notification.
  Future<NotificationItem> createNotification(NotificationItem item) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    _notifications.insert(0, item);
    return item;
  }

  /// Populate robust corporate notification scenarios.
  static List<NotificationItem> _buildDefaultNotifications() {
    final now = DateTime.now();

    return [
      // 1. Approval: Delta Airlines Travel Expense
      NotificationItem(
        id: 'notif-01',
        title: 'Alex approved your travel expense',
        message: 'Delta Air Lines: Round-trip JFK to SFO - \$845.00',
        timestamp: DateTime(now.year, now.month, now.day, 10, 42),
        type: NotificationType.expenseApproved,
        isRead: false,
        referenceId: 'exp-101',
        actionUrl: '/transaction-detail?id=exp-101',
      ),

      // 2. Policy Warning: Duplicate Claim
      NotificationItem(
        id: 'notif-02',
        title: 'Policy Alert: Duplicate claim detected',
        message: 'Uber Technologies (\$54.20) appears twice on Mar 12',
        timestamp: DateTime(now.year, now.month, now.day, 9, 15),
        type: NotificationType.policyAlert,
        isRead: false,
        referenceId: 'exp-103',
        actionUrl: '/transaction-detail?id=exp-103',
      ),

      // 3. System Insights: Spend Analytics
      NotificationItem(
        id: 'notif-03',
        title: 'Monthly spend summary is ready',
        message: 'Your team is 12% under budget for this period.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        type: NotificationType.system,
        isRead: true,
        actionUrl: '/insights',
      ),

      // 4. Card Alert: 80% Limit Warning
      NotificationItem(
        id: 'notif-04',
        title: 'Card Limit Warning: 80% Reached',
        message: 'Software Subs card has reached \$1,200 of \$1,500 limit.',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        type: NotificationType.cardLimitWarning,
        isRead: true,
        referenceId: 'card-02',
        actionUrl: '/cards',
      ),

      // 5. Approval Required: AWS Cloud Infrastructure
      NotificationItem(
        id: 'notif-05',
        title: 'Approval Required: AWS Cloud Infrastructure',
        message: 'DevOps team requested infrastructure reimbursement of \$430.00.',
        timestamp: now.subtract(const Duration(days: 3, hours: 4)),
        type: NotificationType.approvalRequest,
        isRead: false,
        referenceId: 'exp-102',
        actionUrl: '/approvals',
      ),

      // 6. Security Notice: New Login
      NotificationItem(
        id: 'notif-06',
        title: 'Security Alert: New device login',
        message: 'Sign-in detected from macOS Chrome in San Francisco, CA.',
        timestamp: now.subtract(const Duration(days: 5, hours: 1)),
        type: NotificationType.system,
        isRead: true,
      ),
    ];
  }
}
