import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/models/notification_item.dart';
import 'package:expense_guard/features/notifications/providers/notifications_provider.dart';

void main() {
  group('NotificationsProvider Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads initial notifications with correct unread count', () {
      final state = container.read(notificationsProvider);
      expect(state.items.length, 6);
      expect(state.unreadCount, 3); // notif-01, notif-02, notif-05 are unread
      expect(state.selectedFilter, NotificationFilter.all);
    });

    test('Groups notifications into Today, Yesterday, and Earlier', () {
      final state = container.read(notificationsProvider);
      final groups = state.groupedItems;

      expect(groups.containsKey('Today'), isTrue);
      expect(groups['Today']!.length, 2); // notif-01, notif-02

      expect(groups.containsKey('Yesterday'), isTrue);
      expect(groups['Yesterday']!.length, 2); // notif-03, notif-04

      expect(groups.containsKey('Earlier'), isTrue);
      expect(groups['Earlier']!.length, 2); // notif-05, notif-06
    });

    test('markAsRead marks specific item as read and updates unreadCount', () {
      final notifier = container.read(notificationsProvider.notifier);

      notifier.markAsRead('notif-01');

      final state = container.read(notificationsProvider);
      final item = state.items.firstWhere((n) => n.id == 'notif-01');
      expect(item.isRead, isTrue);
      expect(state.unreadCount, 2);
    });

    test('markAllAsRead marks all notifications as read', () {
      final notifier = container.read(notificationsProvider.notifier);

      notifier.markAllAsRead();

      final state = container.read(notificationsProvider);
      expect(state.unreadCount, 0);
      expect(state.items.every((n) => n.isRead), isTrue);
    });

    test('removeNotification deletes target item', () {
      final notifier = container.read(notificationsProvider.notifier);

      notifier.removeNotification('notif-01');

      final state = container.read(notificationsProvider);
      expect(state.items.length, 5);
      expect(state.items.any((n) => n.id == 'notif-01'), isFalse);
    });

    test('Filter by Unread returns only unread items', () {
      final notifier = container.read(notificationsProvider.notifier);

      notifier.setFilter(NotificationFilter.unread);

      final state = container.read(notificationsProvider);
      expect(state.filteredItems.length, 3);
      expect(state.filteredItems.every((n) => !n.isRead), isTrue);
    });

    test('Filter by Alerts returns policy and card limit warnings', () {
      final notifier = container.read(notificationsProvider.notifier);

      notifier.setFilter(NotificationFilter.alerts);

      final state = container.read(notificationsProvider);
      expect(state.filteredItems.length, 2);
      expect(
        state.filteredItems.every(
          (n) =>
              n.type == NotificationType.policyAlert ||
              n.type == NotificationType.cardLimitWarning,
        ),
        isTrue,
      );
    });

    test('Search query matches title or message text', () {
      final notifier = container.read(notificationsProvider.notifier);

      notifier.setSearchQuery('Starbucks');

      final state = container.read(notificationsProvider);
      expect(state.filteredItems.length, 1);
      expect(state.filteredItems.first.id, 'notif-02');
    });
  });
}
