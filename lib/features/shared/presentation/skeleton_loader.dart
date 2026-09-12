import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

/// Wraps widgets with a Pastel Flat themed shimmer effect.
class PastelShimmer extends StatelessWidget {
  const PastelShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return Shimmer.fromColors(
      baseColor: baseColor ?? colors.cardSurfaceAlt,
      highlightColor: highlightColor ?? Colors.white.withValues(alpha: 0.7),
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// Generic skeleton box with rounded corners and optional neo-brutalist border.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.hasBorder = false,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.cardSurfaceAlt,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder
            ? Border.all(color: colors.borderDark.withValues(alpha: 0.15), width: 1.0)
            : null,
      ),
    );
  }
}

/// Skeleton loader for Home Dashboard screen.
class HomeSkeletonLoader extends StatelessWidget {
  const HomeSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return PastelShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spend Summary Card
            const SkeletonBox(
              height: 180,
              borderRadius: AppTheme.cardRadius,
              hasBorder: true,
            ),
            const SizedBox(height: 20),

            // Quick Actions Title & Row
            const SkeletonBox(width: 120, height: 18, borderRadius: 4),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: SkeletonBox(height: 72, borderRadius: 14, hasBorder: true)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 72, borderRadius: 14, hasBorder: true)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 72, borderRadius: 14, hasBorder: true)),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Transactions Title
            const SkeletonBox(width: 160, height: 18, borderRadius: 4),
            const SizedBox(height: 14),

            // Transaction items
            for (int i = 0; i < 4; i++) ...[
              const SkeletonBox(
                height: 68,
                borderRadius: AppTheme.buttonRadius,
                hasBorder: true,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for Corporate Cards screen.
class CardsSkeletonLoader extends StatelessWidget {
  const CardsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return PastelShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
              child: SkeletonBox(width: 160, height: 26, borderRadius: 6),
            ),
            const SizedBox(height: 16),

            // Card Carousel Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
              child: const SkeletonBox(
                height: 210,
                borderRadius: AppTheme.cardRadius,
                hasBorder: true,
              ),
            ),
            const SizedBox(height: 16),

            // Dots indicator
            Center(child: const SkeletonBox(width: 60, height: 8, borderRadius: 4)),
            const SizedBox(height: 20),

            // Limit Progress Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
              child: const SkeletonBox(
                height: 90,
                borderRadius: AppTheme.cardRadius,
                hasBorder: true,
              ),
            ),
            const SizedBox(height: 20),

            // Management Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
              child: Column(
                children: const [
                  SkeletonBox(height: 64, borderRadius: AppTheme.cardRadius, hasBorder: true),
                  SizedBox(height: 12),
                  SkeletonBox(height: 64, borderRadius: AppTheme.cardRadius, hasBorder: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for Approvals Queue screen.
class ApprovalsSkeletonLoader extends StatelessWidget {
  const ApprovalsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return PastelShimmer(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips
            Row(
              children: const [
                SkeletonBox(width: 70, height: 34, borderRadius: 18),
                SizedBox(width: 8),
                SkeletonBox(width: 90, height: 34, borderRadius: 18),
                SizedBox(width: 8),
                SkeletonBox(width: 80, height: 34, borderRadius: 18),
              ],
            ),
            const SizedBox(height: 20),

            // Approval Cards
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, _) => const SkeletonBox(
                  height: 130,
                  borderRadius: AppTheme.cardRadius,
                  hasBorder: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for Spend Insights screen.
class InsightsSkeletonLoader extends StatelessWidget {
  const InsightsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return PastelShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        child: Column(
          children: [
            // Budget banner
            const SkeletonBox(
              height: 60,
              borderRadius: AppTheme.cardRadius,
              hasBorder: true,
            ),
            const SizedBox(height: 16),

            // Time range chips
            Row(
              children: const [
                Expanded(child: SkeletonBox(height: 38, borderRadius: 18)),
                SizedBox(width: 8),
                Expanded(child: SkeletonBox(height: 38, borderRadius: 18)),
                SizedBox(width: 8),
                Expanded(child: SkeletonBox(height: 38, borderRadius: 18)),
                SizedBox(width: 8),
                Expanded(child: SkeletonBox(height: 38, borderRadius: 18)),
              ],
            ),
            const SizedBox(height: 20),

            // Chart Card Placeholder
            const SkeletonBox(
              height: 260,
              borderRadius: AppTheme.cardRadius,
              hasBorder: true,
            ),
            const SizedBox(height: 20),

            // Trend Card Placeholder
            const SkeletonBox(
              height: 180,
              borderRadius: AppTheme.cardRadius,
              hasBorder: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for Notifications Center screen.
class NotificationsSkeletonLoader extends StatelessWidget {
  const NotificationsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return PastelShimmer(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            Row(
              children: const [
                SkeletonBox(width: 60, height: 32, borderRadius: 18),
                SizedBox(width: 8),
                SkeletonBox(width: 80, height: 32, borderRadius: 18),
                SizedBox(width: 8),
                SkeletonBox(width: 70, height: 32, borderRadius: 18),
              ],
            ),
            const SizedBox(height: 20),

            // Section Header
            const SkeletonBox(width: 80, height: 16, borderRadius: 4),
            const SizedBox(height: 12),

            // Notification Cards
            for (int i = 0; i < 3; i++) ...[
              const SkeletonBox(
                height: 90,
                borderRadius: AppTheme.cardRadius,
                hasBorder: true,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
