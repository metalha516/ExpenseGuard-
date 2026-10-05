import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/approvals/models/approval_item.dart';
import 'package:expense_guard/features/approvals/providers/approvals_provider.dart';
import 'package:expense_guard/features/shared/presentation/skeleton_loader.dart';

/// Screen displaying the manager and finance Approvals Queue with AI anomaly scores,
/// policy violation badges, and swipe-to-approve / swipe-to-reject interactions.
/// Based on Stitch Screen IDs:
/// - 0e59c7e30fdf4daf8159c06f687d9ef6 (Light - Pastel Flat)
/// - d96c040e831d407685a8cbc4f5841e20 (Dark)
class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  late final TextEditingController _searchController;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(approvalsProvider);
    final notifier = ref.read(approvalsProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Approvals Queue',
              style: context.headlineMd.copyWith(fontWeight: FontWeight.w800),
            ),
            if (state.pendingCount > 0)
              Text(
                '${state.pendingCount} items requiring review (\$${state.totalPendingAmount.toStringAsFixed(2)})',
                style: context.metadataText.copyWith(
                  color: colors.borderDark.withValues(alpha: 0.65),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('approvals_search_toggle_button'),
            icon: Icon(
              _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
              color: colors.borderDark,
            ),
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchController.clear();
                  notifier.setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            key: const Key('approvals_reset_button'),
            tooltip: 'Reset Demo Queue',
            icon: Icon(
              Icons.restart_alt_rounded,
              color: colors.borderDark,
            ),
            onPressed: () {
              notifier.reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Approvals queue reset to initial demo state'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const ApprovalsSkeletonLoader(key: Key('approvals_skeleton_loader'))
            : Column(
          children: [
            // Search field (if expanded)
            if (_isSearchExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.marginMobile,
                  vertical: 8.0,
                ),
                child: TextField(
                  key: const Key('approvals_search_field'),
                  controller: _searchController,
                  onChanged: notifier.setSearchQuery,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search employee, merchant, or policy...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
              ),

            // Filter Chips Bar
            _buildFilterTabs(colors, state, notifier),

            // Content List or Empty State
            Expanded(
              child: state.filteredPendingItems.isEmpty
                  ? _buildEmptyState(colors, state, notifier)
                  : _buildApprovalsList(colors, isDark, state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top filter pill tabs.
  Widget _buildFilterTabs(
    AppPastelColors colors,
    ApprovalsState state,
    ApprovalsNotifier notifier,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.marginMobile,
        vertical: 10.0,
      ),
      child: Row(
        children: [
          _buildFilterChip(
            key: const Key('filter_chip_all'),
            label: 'All (${state.pendingCount})',
            isSelected: state.filter == ApprovalsFilter.all,
            colors: colors,
            onSelected: () => notifier.setFilter(ApprovalsFilter.all),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            key: const Key('filter_chip_high_risk'),
            label: 'High Risk (${state.highRiskCount})',
            icon: Icons.warning_amber_rounded,
            badgeColor: const Color(0xFFFFDAD6),
            isSelected: state.filter == ApprovalsFilter.highRisk,
            colors: colors,
            onSelected: () => notifier.setFilter(ApprovalsFilter.highRisk),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            key: const Key('filter_chip_standard'),
            label: 'Standard (${state.standardCount})',
            icon: Icons.verified_user_rounded,
            isSelected: state.filter == ApprovalsFilter.standard,
            colors: colors,
            onSelected: () => notifier.setFilter(ApprovalsFilter.standard),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required Key key,
    required String label,
    required bool isSelected,
    required AppPastelColors colors,
    required VoidCallback onSelected,
    IconData? icon,
    Color? badgeColor,
  }) {
    final bgColor = isSelected
        ? (badgeColor ?? colors.mint)
        : colors.cardSurface;

    return InkWell(
      key: key,
      onTap: onSelected,
      borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.chipRadius),
          border: Border.all(
            color: colors.borderDark,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: colors.borderDark),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: colors.borderDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of grouped approvals cards.
  Widget _buildApprovalsList(
    AppPastelColors colors,
    bool isDark,
    ApprovalsState state,
    ApprovalsNotifier notifier,
  ) {
    final showAll = state.filter == ApprovalsFilter.all;
    final showHighRisk = state.filter == ApprovalsFilter.highRisk || showAll;
    final showStandard = state.filter == ApprovalsFilter.standard || showAll;

    final highRiskItems = state.filteredPendingItems
        .where((i) => i.isHighRisk)
        .toList();
    final standardItems = state.filteredPendingItems
        .where((i) => !i.isHighRisk)
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.marginMobile,
        vertical: 8.0,
      ),
      children: [
        // 1. High Risk Group
        if (showHighRisk && highRiskItems.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'High Risk / Out of Policy',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFBA1A1A),
            count: highRiskItems.length,
            badgeColor: const Color(0xFFFFDAD6),
            badgeTextColor: const Color(0xFF93000A),
            colors: colors,
          ),
          const SizedBox(height: 12),
          for (final item in highRiskItems) ...[
            _buildDismissibleApprovalCard(
              context,
              colors,
              isDark,
              item,
              notifier,
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 12),
        ],

        // 2. Standard Group
        if (showStandard && standardItems.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Standard Routine',
            icon: Icons.verified_user_rounded,
            iconColor: colors.primarySage,
            count: standardItems.length,
            badgeColor: colors.mintDim,
            badgeTextColor: colors.borderDark,
            colors: colors,
          ),
          const SizedBox(height: 12),
          for (final item in standardItems) ...[
            _buildDismissibleApprovalCard(
              context,
              colors,
              isDark,
              item,
              notifier,
            ),
            const SizedBox(height: 16),
          ],
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
    required int count,
    required Color badgeColor,
    required Color badgeTextColor,
    required AppPastelColors colors,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: iconColor,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(AppTheme.chipRadius),
            border: Border.all(color: colors.borderDark, width: 1.0),
          ),
          child: Text(
            '$count Pending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeTextColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a swipeable Dismissible approval card supporting swipe-to-approve
  /// (startToEnd) and swipe-to-reject (endToStart).
  Widget _buildDismissibleApprovalCard(
    BuildContext context,
    AppPastelColors colors,
    bool isDark,
    ApprovalItem item,
    ApprovalsNotifier notifier,
  ) {
    return Dismissible(
      key: Key('approval_dismissible_${item.id}'),
      direction: DismissDirection.horizontal,
      background: _buildSwipeActionBackground(
        color: colors.mint,
        icon: Icons.check_circle_rounded,
        label: 'Approve',
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        colors: colors,
      ),
      secondaryBackground: _buildSwipeActionBackground(
        color: const Color(0xFFFFDAD6),
        icon: Icons.flag_rounded,
        label: 'Flag / Reject',
        textColor: const Color(0xFF93000A),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        colors: colors,
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          notifier.approve(item.id);
          _showFeedbackSnackBar(
            context,
            message:
                'Approved ${item.employeeName}\'s \$${item.amount.toStringAsFixed(2)} expense at ${item.merchant}',
            itemId: item.id,
            notifier: notifier,
          );
        } else {
          notifier.reject(item.id);
          _showFeedbackSnackBar(
            context,
            message:
                'Flagged ${item.employeeName}\'s \$${item.amount.toStringAsFixed(2)} expense at ${item.merchant}',
            itemId: item.id,
            notifier: notifier,
          );
        }
      },
      child: _buildApprovalCardContent(context, colors, isDark, item, notifier),
    );
  }

  /// Swipe background container with icon, label, and high-contrast border.
  Widget _buildSwipeActionBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
    required EdgeInsets padding,
    required AppPastelColors colors,
    Color? textColor,
  }) {
    final effectiveTextColor = textColor ?? colors.borderDark;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
      ),
      alignment: alignment,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: effectiveTextColor, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: effectiveTextColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Main Card Body displaying employee, merchant, amount, AI score, and policy warnings.
  Widget _buildApprovalCardContent(
    BuildContext context,
    AppPastelColors colors,
    bool isDark,
    ApprovalItem item,
    ApprovalsNotifier notifier,
  ) {
    return InkWell(
      key: Key('approval_card_${item.id}'),
      onTap: () {
        // Tapping card opens the comprehensive Transaction Detail screen
        context.push('/transaction-detail?id=${item.transactionId}');
      },
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: item.isHighRisk
                ? (isDark ? const Color(0xFFFFB4AB) : colors.borderDark)
                : colors.borderDark,
            width: AppTheme.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.borderDark.withValues(alpha: 0.08),
              offset: const Offset(3, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar / Category Icon + Employee Info + Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category / Avatar Icon container
                _buildCategoryAvatar(colors, item),
                const SizedBox(width: 12),

                // Employee & Merchant
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.employeeName,
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.borderDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.merchant} • ${_formatShortDate(item.date)}',
                        style: context.metadataText.copyWith(
                          color: colors.borderDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.amount.toStringAsFixed(2)}',
                      style: context.headlineMd.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category,
                      style: context.metadataText.copyWith(
                        color: colors.borderDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // AI Fraud & Anomaly Score Badge + Status Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildFraudRiskScoreBadge(colors, item),
                if (item.hasReceipt)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.tagBackground,
                      borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                      border: Border.all(
                        color: colors.borderDark.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 13,
                          color: colors.borderDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Receipt Attached',
                          style: context.metadataText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.borderDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                for (final tag in item.violationTags)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isHighRisk
                          ? const Color(0xFFFFDAD6)
                          : colors.tagBackground,
                      borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                      border: Border.all(
                        color: item.isHighRisk
                            ? const Color(0xFF93000A)
                            : colors.borderDark.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: item.isHighRisk
                            ? const Color(0xFF93000A)
                            : colors.borderDark,
                      ),
                    ),
                  ),
              ],
            ),

            // Policy Violation Warning Box (High Risk)
            if (item.policyWarning != null) ...[
              const SizedBox(height: 12),
              Container(
                key: Key('policy_warning_${item.id}'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3B1E1E)
                      : const Color(0xFFFFDAD6).withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  border: Border.all(
                    color: const Color(0xFFBA1A1A),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.policy_rounded,
                      size: 16,
                      color: Color(0xFFBA1A1A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.policyWarning!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFBA1A1A),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Employee Justification Note (Italic quote callout)
            if (item.userNote != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.cardSurfaceAlt,
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  border: Border.all(
                    color: colors.borderDark.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  '"${item.userNote}"',
                  style: context.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: colors.borderDark.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(
              color: colors.borderDark.withValues(alpha: 0.15),
              height: 1,
            ),
            const SizedBox(height: 10),

            // Footer: Direct Action Buttons & Swipe Hints
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Swipe Hints
                Row(
                  children: [
                    Icon(
                      Icons.swipe_rounded,
                      size: 14,
                      color: colors.borderDark.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe to action',
                      style: context.metadataText.copyWith(
                        color: colors.borderDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),

                // Direct Clickable Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reject / Flag Button
                    InkWell(
                      key: Key('reject_button_${item.id}'),
                      onTap: () {
                        notifier.reject(item.id);
                        _showFeedbackSnackBar(
                          context,
                          message:
                              'Flagged ${item.employeeName}\'s \$${item.amount.toStringAsFixed(2)} expense',
                          itemId: item.id,
                          notifier: notifier,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAD6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.borderDark,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.flag_rounded,
                              size: 14,
                              color: Color(0xFF93000A),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Flag',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF93000A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Approve Button
                    InkWell(
                      key: Key('approve_button_${item.id}'),
                      onTap: () {
                        notifier.approve(item.id);
                        _showFeedbackSnackBar(
                          context,
                          message:
                              'Approved ${item.employeeName}\'s \$${item.amount.toStringAsFixed(2)} expense',
                          itemId: item.id,
                          notifier: notifier,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.mint,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.borderDark,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: colors.borderDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.borderDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Category icon avatar with pastel flat container.
  Widget _buildCategoryAvatar(AppPastelColors colors, ApprovalItem item) {
    Color bg;
    IconData icon;

    switch (item.iconName) {
      case 'flight':
        bg = colors.mint;
        icon = Icons.flight_rounded;
        break;
      case 'restaurant':
        bg = colors.peach;
        icon = Icons.restaurant_rounded;
        break;
      case 'hotel':
        bg = colors.skyBlue;
        icon = Icons.hotel_rounded;
        break;
      case 'laptop_mac':
        bg = colors.lavender;
        icon = Icons.laptop_mac_rounded;
        break;
      default:
        bg = colors.tagBackground;
        icon = Icons.receipt_rounded;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderDark,
          width: 1.2,
        ),
      ),
      child: Icon(icon, color: colors.borderDark, size: 22),
    );
  }

  /// AI Fraud & Anomaly score indicator pill.
  Widget _buildFraudRiskScoreBadge(
    AppPastelColors colors,
    ApprovalItem item,
  ) {
    final score = item.fraudRiskScore;
    Color pillColor;
    Color textColor;
    IconData icon;
    String scoreLabel;

    if (score >= 70) {
      pillColor = const Color(0xFFFFDAD6);
      textColor = const Color(0xFF93000A);
      icon = Icons.warning_amber_rounded;
      scoreLabel = 'AI Risk: $score/100 ⚠️ High Anomaly';
    } else if (score >= 40) {
      pillColor = colors.peach;
      textColor = colors.borderDark;
      icon = Icons.bolt_rounded;
      scoreLabel = 'AI Risk: $score/100 • Elevated';
    } else {
      pillColor = colors.mint;
      textColor = colors.borderDark;
      icon = Icons.check_circle_rounded;
      scoreLabel = 'AI Score: $score/100 ✅ Clean';
    }

    return Container(
      key: Key('fraud_score_badge_${item.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        border: Border.all(
          color: colors.borderDark,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            scoreLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state rendered when all items in the queue are processed.
  Widget _buildEmptyState(
    AppPastelColors colors,
    ApprovalsState state,
    ApprovalsNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.mint,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.borderDark,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.borderDark.withValues(alpha: 0.12),
                    offset: const Offset(3, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.done_all_rounded,
                color: colors.borderDark,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All Caught Up! 🎉',
              style: context.headlineLg.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Zero pending expenses in this approvals queue. All team submissions have been processed.',
              style: context.bodyMedium.copyWith(
                color: colors.borderDark.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: const Key('empty_reset_queue_button'),
              onPressed: () => notifier.reset(),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset Demo Queue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.cardSurface,
                foregroundColor: colors.borderDark,
                side: BorderSide(
                  color: colors.borderDark,
                  width: AppTheme.borderWidth,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SnackBar feedback with undo action on swipe or button approval.
  void _showFeedbackSnackBar(
    BuildContext context, {
    required String message,
    required String itemId,
    required ApprovalsNotifier notifier,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => notifier.undo(itemId),
        ),
      ),
    );
  }

  static String _formatShortDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
