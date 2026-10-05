import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/models/notification_item.dart';
import 'package:expense_guard/features/notifications/providers/notifications_provider.dart';
import 'package:expense_guard/features/shared/presentation/skeleton_loader.dart';

/// Screen displaying the Notifications Center grouped by Today, Yesterday, and Earlier.
/// Based on Stitch Screen ID: 2cff37e1207d48b6a6df7839ed672afc ("Notifications Center").
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final grouped = state.groupedItems;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? TextField(
                key: const Key('notifications_search_input'),
                controller: _searchController,
                autofocus: true,
                style: context.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search notifications...',
                  border: InputBorder.none,
                  hintStyle: context.bodyLarge.copyWith(
                    color: colors.borderDark.withValues(alpha: 0.5),
                  ),
                ),
                onChanged: notifier.setSearchQuery,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Notifications'),
                  if (state.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      key: const Key('header_unread_badge'),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.mint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.borderDark, width: 1.0),
                      ),
                      child: Text(
                        '${state.unreadCount} new',
                        style: context.metadataText.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.borderDark,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        actions: [
          // Search Toggle
          IconButton(
            key: const Key('toggle_search_button'),
            tooltip: _isSearchOpen ? 'Close Search' : 'Search',
            icon: Icon(
              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              color: colors.borderDark,
            ),
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _searchController.clear();
                  notifier.setSearchQuery('');
                }
              });
            },
          ),

          // Mark All Read Action Button
          if (state.unreadCount > 0)
            TextButton.icon(
              key: const Key('mark_all_read_button'),
              onPressed: () {
                notifier.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: Icon(
                Icons.done_all_rounded,
                size: 16,
                color: colors.primarySage,
              ),
              label: Text(
                'Mark read',
                style: context.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primarySage,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const NotificationsSkeletonLoader(key: Key('notifications_skeleton_loader'))
            : Column(
                children: [
            // Filter Chips Bar
            _buildFilterChips(colors, state, notifier),
            const Divider(height: 1, thickness: 1),

            // Grouped Notification List or Empty State
            Expanded(
              child: grouped.isEmpty
                  ? _buildEmptyState(colors, state, notifier)
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.marginMobile,
                        vertical: 16,
                      ),
                      children: [
                        for (final entry in grouped.entries) ...[
                          _buildGroupSection(
                            context,
                            colors,
                            groupTitle: entry.key,
                            items: entry.value,
                            notifier: notifier,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter chips bar with All, Unread, Alerts, Approvals.
  Widget _buildFilterChips(
    AppPastelColors colors,
    NotificationsState state,
    NotificationsNotifier notifier,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile, vertical: 12),
      child: Row(
        children: NotificationFilter.values.map((filter) {
          final isSelected = state.selectedFilter == filter;
          String label = filter.label;
          if (filter == NotificationFilter.unread && state.unreadCount > 0) {
            label = 'Unread (${state.unreadCount})';
          }

          Color chipColor;
          switch (filter) {
            case NotificationFilter.all:
              chipColor = isSelected ? colors.primarySage : colors.cardSurfaceAlt;
              break;
            case NotificationFilter.unread:
              chipColor = isSelected ? colors.mint : colors.cardSurfaceAlt;
              break;
            case NotificationFilter.alerts:
              chipColor = isSelected ? colors.peach : colors.cardSurfaceAlt;
              break;
            case NotificationFilter.approvals:
              chipColor = isSelected ? colors.skyBlue : colors.cardSurfaceAlt;
              break;
          }

          final textColor = (isSelected && filter == NotificationFilter.all)
              ? Colors.white
              : colors.borderDark;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              key: Key('filter_${filter.name}'),
              onTap: () => notifier.setFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.borderDark,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.borderDark.withValues(alpha: 0.12),
                            offset: const Offset(1.5, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: context.labelMd.copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Section group header (TODAY, YESTERDAY, EARLIER) and notification cards.
  Widget _buildGroupSection(
    BuildContext context,
    AppPastelColors colors, {
    required String groupTitle,
    required List<NotificationItem> items,
    required NotificationsNotifier notifier,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                groupTitle.toUpperCase(),
                style: context.metadataText.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: colors.borderDark.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.cardSurfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colors.borderDark.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${items.length}',
                  style: context.metadataText.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.borderDark.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Notification Cards
        ...items.map((item) {
          return _buildNotificationCard(
            context,
            colors,
            item: item,
            notifier: notifier,
          );
        }),
      ],
    );
  }

  /// Single Notification Card with pastel iconography and dismissible gesture.
  Widget _buildNotificationCard(
    BuildContext context,
    AppPastelColors colors, {
    required NotificationItem item,
    required NotificationsNotifier notifier,
  }) {
    final iconConfig = _getIconConfig(colors, item.type);
    final formattedTime = _formatTimestamp(item.timestamp);

    return Padding(
      key: Key('notif_card_${item.id}'),
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('dismiss_${item.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE57373),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: colors.borderDark, width: 1.5),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
              SizedBox(width: 6),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        onDismissed: (_) {
          notifier.removeNotification(item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dismissed: ${item.title}'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Undo',
                textColor: colors.mint,
                onPressed: () {
                  notifier.resetToDefault();
                },
              ),
            ),
          );
        },
        child: InkWell(
          key: Key('card_tap_${item.id}'),
          onTap: () {
            // 1. Mark as read on tap
            if (!item.isRead) {
              notifier.markAsRead(item.id);
            }

            // 2. Route if actionUrl is present and GoRouter is available
            if (item.actionUrl != null) {
              try {
                context.push(item.actionUrl!);
              } catch (_) {
                // Ignore navigation when rendered without GoRouter in standalone tests
              }
            }
          },
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Container(
            decoration: BoxDecoration(
              color: item.isRead
                  ? colors.cardSurfaceAlt.withValues(alpha: 0.5)
                  : colors.cardSurface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(
                color: item.type == NotificationType.policyAlert
                    ? const Color(0xFFE57373).withValues(alpha: 0.5)
                    : colors.borderDark,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.borderDark.withValues(
                    alpha: item.isRead ? 0.03 : 0.08,
                  ),
                  offset: const Offset(2, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Specific Pastel Iconography Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconConfig.backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.borderDark,
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    iconConfig.icon,
                    size: 22,
                    color: iconConfig.iconColor,
                  ),
                ),
                const SizedBox(width: 14),

                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: context.bodyLarge.copyWith(
                                fontWeight: item.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: colors.borderDark,
                              ),
                            ),
                          ),
                          // Unread Green Pill Dot Indicator
                          if (!item.isRead)
                            Container(
                              key: Key('unread_indicator_${item.id}'),
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6, top: 4),
                              decoration: BoxDecoration(
                                color: colors.primarySage,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: context.bodyMedium.copyWith(
                          color: colors.borderDark.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: colors.borderDark.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: context.metadataText.copyWith(
                              color: colors.borderDark.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                          if (item.actionUrl != null) ...[
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  'View',
                                  style: context.metadataText.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.primarySage,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: colors.primarySage,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Empty state when no notifications match active filters or search.
  Widget _buildEmptyState(
    AppPastelColors colors,
    NotificationsState state,
    NotificationsNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.marginMobile * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.mint,
                shape: BoxShape.circle,
                border: Border.all(color: colors.borderDark, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: colors.borderDark.withValues(alpha: 0.1),
                    offset: const Offset(3, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.mark_email_read_rounded,
                size: 42,
                color: colors.primarySage,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All Caught Up!',
              style: context.headlineMd.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No notifications match "${state.searchQuery}".'
                  : 'No ${state.selectedFilter != NotificationFilter.all ? state.selectedFilter.label.toLowerCase() : ""} notifications right now.',
              style: context.bodyMedium.copyWith(
                color: colors.borderDark.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: const Key('reset_notifications_button'),
              onPressed: () {
                notifier.resetToDefault();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset Demo Notifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.cardSurface,
                foregroundColor: colors.borderDark,
                elevation: 0,
                side: BorderSide(color: colors.borderDark, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps NotificationType to specific Pastel Flat icon & container colors.
  _NotificationIconConfig _getIconConfig(
    AppPastelColors colors,
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType.expenseApproved:
      case NotificationType.approvalRequest:
        return _NotificationIconConfig(
          icon: Icons.check_circle_rounded,
          backgroundColor: colors.mint,
          iconColor: colors.primarySage,
        );
      case NotificationType.expenseRejected:
        return _NotificationIconConfig(
          icon: Icons.cancel_rounded,
          backgroundColor: colors.peach,
          iconColor: const Color(0xFFD32F2F),
        );
      case NotificationType.policyAlert:
        return _NotificationIconConfig(
          icon: Icons.warning_rounded,
          backgroundColor: colors.peach,
          iconColor: const Color(0xFFD32F2F),
        );
      case NotificationType.cardLimitWarning:
        return _NotificationIconConfig(
          icon: Icons.credit_card_rounded,
          backgroundColor: colors.skyBlue,
          iconColor: colors.borderDark,
        );
      case NotificationType.system:
        return _NotificationIconConfig(
          icon: Icons.insights_rounded,
          backgroundColor: colors.lavender,
          iconColor: colors.borderDark,
        );
    }
  }

  /// Formats timestamp into user-friendly strings.
  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _NotificationIconConfig {
  const _NotificationIconConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}
