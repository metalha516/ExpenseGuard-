import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/models/notification_item.dart';

/// Filter categories for the Notifications Center.
enum NotificationFilter {
  all,
  unread,
  alerts,
  approvals;

  String get label {
    switch (this) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.unread:
        return 'Unread';
      case NotificationFilter.alerts:
        return 'Alerts';
      case NotificationFilter.approvals:
        return 'Approvals';
    }
  }
}

/// State representing notification items, active filter, and search query.
@immutable
class NotificationsState {
  const NotificationsState({
    required this.items,
    this.selectedFilter = NotificationFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
  });

  final List<NotificationItem> items;
  final NotificationFilter selectedFilter;
  final String searchQuery;
  final bool isLoading;

  /// Total count of unread notifications.
  int get unreadCount => items.where((item) => !item.isRead).length;

  /// Notifications filtered by active category and search query.
  List<NotificationItem> get filteredItems {
    return items.where((item) {
      // 1. Filter by category
      switch (selectedFilter) {
        case NotificationFilter.all:
          break;
        case NotificationFilter.unread:
          if (item.isRead) return false;
          break;
        case NotificationFilter.alerts:
          if (item.type != NotificationType.policyAlert &&
              item.type != NotificationType.cardLimitWarning) {
            return false;
          }
          break;
        case NotificationFilter.approvals:
          if (item.type != NotificationType.approvalRequest &&
              item.type != NotificationType.expenseApproved &&
              item.type != NotificationType.expenseRejected) {
            return false;
          }
          break;
      }

      // 2. Filter by search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(query);
        final matchMessage = item.message.toLowerCase().contains(query);
        if (!matchTitle && !matchMessage) return false;
      }

      return true;
    }).toList();
  }

  /// Notifications grouped by "Today", "Yesterday", and "Earlier".
  Map<String, List<NotificationItem>> get groupedItems {
    final filtered = filteredItems;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final List<NotificationItem> todayList = [];
    final List<NotificationItem> yesterdayList = [];
    final List<NotificationItem> earlierList = [];

    for (final item in filtered) {
      if (item.timestamp.isAfter(todayStart) ||
          item.timestamp.isAtSameMomentAs(todayStart)) {
        todayList.add(item);
      } else if (item.timestamp.isAfter(yesterdayStart) ||
          item.timestamp.isAtSameMomentAs(yesterdayStart)) {
        yesterdayList.add(item);
      } else {
        earlierList.add(item);
      }
    }

    final Map<String, List<NotificationItem>> groups = {};
    if (todayList.isNotEmpty) groups['Today'] = todayList;
    if (yesterdayList.isNotEmpty) groups['Yesterday'] = yesterdayList;
    if (earlierList.isNotEmpty) groups['Earlier'] = earlierList;

    return groups;
  }

  NotificationsState copyWith({
    List<NotificationItem>? items,
    NotificationFilter? selectedFilter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsState &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items) &&
          selectedFilter == other.selectedFilter &&
          searchQuery == other.searchQuery &&
          isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        selectedFilter,
        searchQuery,
        isLoading,
      );
}

/// Riverpod Notifier managing notifications state, read status, and actions.
class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    return NotificationsState(
      items: _buildInitialNotifications(),
    );
  }

  /// Mark a specific notification as read.
  void markAsRead(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList(),
    );
  }

  /// Mark all notifications as read.
  void markAllAsRead() {
    state = state.copyWith(
      items: state.items.map((item) => item.copyWith(isRead: true)).toList(),
    );
  }

  /// Delete / dismiss a notification.
  void removeNotification(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  /// Set the active filter chip.
  void setFilter(NotificationFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Set the search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Reset to initial notifications (useful for testing or demo reset).
  void resetToDefault() {
    state = NotificationsState(
      items: _buildInitialNotifications(),
    );
  }

  static List<NotificationItem> _buildInitialNotifications() {
    final now = DateTime.now();

    return [
      // 1. Today: Approval Success (Stitch Screen 2cff37e1207d48b6a6df7839ed672afc)
      NotificationItem(
        id: 'notif-01',
        title: 'Alex approved your travel expense',
        message: 'Trip to New York HQ - \$845.00',
        timestamp: DateTime(now.year, now.month, now.day, 10, 42),
        type: NotificationType.expenseApproved,
        isRead: false,
        referenceId: 'txn-101',
        actionUrl: '/transaction-detail?id=txn-101',
      ),

      // 2. Today: Policy Warning (Stitch Screen 2cff37e1207d48b6a6df7839ed672afc)
      NotificationItem(
        id: 'notif-02',
        title: 'Policy Alert: Duplicate claim detected',
        message: 'Starbucks (\$12.50) appears twice on Mar 12',
        timestamp: DateTime(now.year, now.month, now.day, 9, 15),
        type: NotificationType.policyAlert,
        isRead: false,
        referenceId: 'txn-102',
        actionUrl: '/transaction-detail?id=txn-102',
      ),

      // 3. Yesterday: Insights / Summary (Stitch Screen 2cff37e1207d48b6a6df7839ed672afc)
      NotificationItem(
        id: 'notif-03',
        title: 'Monthly spend summary is ready',
        message: 'Your February expenses are ready for review.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        type: NotificationType.system,
        isRead: true,
        actionUrl: '/insights',
      ),

      // 4. Yesterday: Card Limit Warning
      NotificationItem(
        id: 'notif-04',
        title: 'Card Limit Warning: 80% Reached',
        message: 'Software Subs card has reached \$1,200 of \$1,500 monthly limit.',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        type: NotificationType.cardLimitWarning,
        isRead: true,
        referenceId: 'card-02',
        actionUrl: '/cards',
      ),

      // 5. Earlier: Approval Request requiring manager review
      NotificationItem(
        id: 'notif-05',
        title: 'Approval Required: AWS Cloud Infrastructure',
        message: 'DevOps Team submitted an infrastructure claim of \$430.00.',
        timestamp: now.subtract(const Duration(days: 3, hours: 4)),
        type: NotificationType.approvalRequest,
        isRead: false,
        referenceId: 'txn-103',
        actionUrl: '/approvals',
      ),

      // 6. Earlier: System Security Alert
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

/// Global provider for notifications state.
final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
