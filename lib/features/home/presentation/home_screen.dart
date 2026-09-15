import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/models/models.dart';
import 'package:expense_guard/features/home/providers/home_provider.dart';
import 'package:expense_guard/features/shared/providers/theme_provider.dart';
import 'package:expense_guard/features/shared/presentation/skeleton_loader.dart';
import 'package:expense_guard/features/shared/presentation/animations/pastel_tap_scale.dart';

/// The Home Dashboard screen featuring spend metrics, quick actions, and recent transactions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);
    final colors = context.pastelColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppTheme.marginMobile,
        elevation: 0,
        title: Row(
          children: [
            // User Avatar
            InkWell(
              onTap: () => context.push('/profile'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.mint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.borderDark,
                    width: AppTheme.borderWidth,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: colors.borderDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ExpenseGuard',
                  style: context.headlineMd.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : colors.primarySage,
                  ),
                ),
                Text(
                  'Good morning, ${homeState.userName}',
                  style: context.metadataText.copyWith(
                    color: isDark ? Colors.white70 : const Color(0xFF6F7975),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Toggle Button
          IconButton(
            key: const Key('home_theme_toggle_button'),
            tooltip: 'Toggle Theme',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? colors.mint : colors.borderDark,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          // Notifications Button with Unread Badge
          IconButton(
            key: const Key('home_notifications_button'),
            tooltip: 'Notifications',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: isDark ? Colors.white : colors.borderDark,
                ),
                if (homeState.unreadNotificationsCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: colors.peach,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.borderDark,
                          width: 1.0,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${homeState.unreadNotificationsCount}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: colors.borderDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: homeState.isLoading
          ? const HomeSkeletonLoader(key: Key('home_skeleton_loader'))
          : RefreshIndicator(
              onRefresh: () => ref.read(homeStateProvider.notifier).refresh(),
              child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.marginMobile,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card: Total Spent vs. Limit
              _SpendSummaryCard(homeState: homeState),
              const SizedBox(height: AppTheme.stackGap),

              // Quick Actions Bento Grid
              const _QuickActionsBento(),
              const SizedBox(height: AppTheme.stackGap),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent transactions',
                    style: context.headlineMd.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/cards'),
                    child: Text(
                      'See all',
                      style: context.labelMd.copyWith(
                        color: isDark ? colors.mint : colors.primarySage,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Transactions List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeState.recentTransactions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final txn = homeState.recentTransactions[index];
                  return _TransactionItemCard(transaction: txn);
                },
              ),
              const SizedBox(height: 80), // Padding above bottom bar / FAB
            ],
          ),
        ),
      ),
    );
  }
}

/// Spend Summary Widget displaying Total Spent vs. Monthly Limit with progress meter.
class _SpendSummaryCard extends StatelessWidget {
  const _SpendSummaryCard({required this.homeState});

  final HomeState homeState;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total spend this month",
                style: context.bodyMd.copyWith(
                  color: isDark ? Colors.white70 : const Color(0xFF6F7975),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.mintDim,
                  borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                  border: Border.all(
                    color: colors.borderDark,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  '${homeState.spendPercentage}% of limit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : colors.borderDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total Spend Display
          Text(
            '\$${homeState.totalSpent.toStringAsFixed(2)}',
            style: context.displayCurrency.copyWith(
              color: isDark ? Colors.white : colors.borderDark,
            ),
          ),
          const SizedBox(height: 14),

          // Spend vs. Limit Progress Meter Bar
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2026)
                      : const Color(0xFFEDEEEF),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: colors.borderDark,
                    width: 1.0,
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: homeState.spendRatio,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.mint,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: colors.borderDark,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metrics Breakdown Row + Quick Add Expense Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _SummaryPillStat(
                    label: 'Approved',
                    amount: '\$${homeState.approvedAmount.toStringAsFixed(0)}',
                    dotColor: colors.mint,
                  ),
                  const SizedBox(width: 16),
                  _SummaryPillStat(
                    label: 'Pending',
                    amount: '\$${homeState.pendingAmount.toStringAsFixed(0)}',
                    dotColor: colors.peach,
                  ),
                  const SizedBox(width: 16),
                  _SummaryPillStat(
                    label: 'Remaining',
                    amount: '\$${homeState.remainingBudget.toStringAsFixed(0)}',
                    dotColor: colors.skyBlue,
                  ),
                ],
              ),
              // Add Expense Button
              ElevatedButton(
                key: const Key('home_add_expense_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.mint,
                  foregroundColor: colors.borderDark,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    side: BorderSide(
                      color: colors.borderDark,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                  elevation: 0,
                ),
                onPressed: () => context.push('/submit-expense'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: colors.borderDark),
                    const SizedBox(width: 4),
                    Text(
                      'Expense',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colors.borderDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPillStat extends StatelessWidget {
  const _SummaryPillStat({
    required this.label,
    required this.amount,
    required this.dotColor,
  });

  final String label;
  final String amount;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.metadataText),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.borderDark,
                  width: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              amount,
              style: context.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Quick Actions Bento Grid matching the Stitch Dashboard design.
class _QuickActionsBento extends StatelessWidget {
  const _QuickActionsBento();

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BentoButton(
                key: const Key('bento_scan_receipt'),
                title: 'Scan Receipt',
                subtitle: 'AI auto-fill',
                icon: Icons.receipt_long_rounded,
                accentColor: colors.skyBlue,
                accentDim: colors.skyBlueDim,
                onTap: () => context.push('/submit-expense'),
              ),
            ),
            const SizedBox(width: AppTheme.gutterMobile),
            Expanded(
              child: _BentoButton(
                key: const Key('bento_cards'),
                title: 'Cards',
                subtitle: 'Limit controls',
                icon: Icons.credit_card_rounded,
                accentColor: colors.peach,
                accentDim: colors.peachDim,
                onTap: () => context.push('/cards'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.gutterMobile),
        Row(
          children: [
            Expanded(
              child: _BentoButton(
                key: const Key('bento_approvals'),
                title: 'Approvals',
                subtitle: 'Team requests',
                icon: Icons.rule_rounded,
                accentColor: colors.lavender,
                accentDim: colors.lavenderDim,
                onTap: () => context.push('/approvals'),
              ),
            ),
            const SizedBox(width: AppTheme.gutterMobile),
            Expanded(
              child: _BentoButton(
                key: const Key('bento_insights'),
                title: 'Insights',
                subtitle: 'Spend trends',
                icon: Icons.donut_large_rounded,
                accentColor: colors.mint,
                accentDim: colors.mintDim,
                onTap: () => context.push('/insights'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoButton extends StatelessWidget {
  const _BentoButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.accentDim,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color accentDim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return PastelTapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: colors.borderDark,
            width: AppTheme.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.borderDark,
                  width: 1.2,
                ),
              ),
              child: Icon(
                icon,
                color: colors.borderDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.metadataText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction item card matching the Stitch Pastel Flat specifications.
class _TransactionItemCard extends StatelessWidget {
  const _TransactionItemCard({required this.transaction});

  final Transaction transaction;

  Color _getBadgeColor(BuildContext context, String category) {
    final colors = context.pastelColors;
    if (category.contains('Meals')) return colors.mint;
    if (category.contains('Transportation')) return colors.lavender;
    if (category.contains('Software') || category.contains('Cloud')) {
      return colors.skyBlue;
    }
    if (category.contains('Travel')) return colors.peach;
    return colors.mint;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_cafe':
        return Icons.local_cafe_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'laptop_mac':
        return Icons.laptop_mac_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final badgeColor = _getBadgeColor(context, transaction.category);
    final iconData = _getIconData(transaction.iconName);

    return PastelTapScale(
      onTap: () => context.push('/transaction-detail?id=${transaction.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: colors.borderDark,
            width: AppTheme.borderWidth,
          ),
        ),
        child: Row(
          children: [
            // Icon Avatar with Hero Transition
            Hero(
              tag: 'receipt_hero_${transaction.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.borderDark,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: colors.borderDark,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Merchant & Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant,
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.category} • •••• ${transaction.cardLast4}',
                    style: context.metadataText,
                  ),
                ],
              ),
            ),

            // Amount & Status Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-\$${transaction.amount.toStringAsFixed(2)}',
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 3),
                _StatusBadge(status: transaction.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color badgeBg;
    IconData icon;
    String label = status.displayName;

    switch (status) {
      case TransactionStatus.autoCleared:
        badgeBg = colors.mint;
        icon = Icons.check_circle_outline_rounded;
        break;
      case TransactionStatus.cleared:
        badgeBg = colors.mintDim;
        icon = Icons.verified_outlined;
        break;
      case TransactionStatus.reviewing:
        badgeBg = colors.peach;
        icon = Icons.schedule_rounded;
        break;
      case TransactionStatus.pending:
        badgeBg = colors.peachDim;
        icon = Icons.hourglass_empty_rounded;
        break;
      case TransactionStatus.flagged:
        badgeBg = const Color(0xFFFFDAD6);
        icon = Icons.warning_amber_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        border: Border.all(
          color: colors.borderDark,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: colors.borderDark),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark && status == TransactionStatus.cleared
                  ? Colors.white
                  : colors.borderDark,
            ),
          ),
        ],
      ),
    );
  }
}
