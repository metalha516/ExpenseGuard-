import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

/// The persistent main shell of ExpenseGuard, providing:
/// - 5-tab stylized Pastel Flat navigation bar (Home, Approvals, Cards, Insights, Profile)
/// - Center docked Floating Action Button (FAB) for the Submit Expense camera flow.
class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell managing tab branches.
  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? colors.mint.withValues(alpha: 0.35)
                  : colors.borderDark.withValues(alpha: 0.18),
              blurRadius: isDark ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          key: const Key('docked_camera_fab'),
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: colors.mint,
          foregroundColor: const Color(0xFF14241E),
          shape: CircleBorder(
            side: BorderSide(
              color: isDark ? const Color(0xFF38433E) : colors.borderDark,
              width: 2.0,
            ),
          ),
          onPressed: () => context.push('/submit-expense'),
          tooltip: 'Submit Expense (Camera)',
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 28,
            color: Color(0xFF14241E),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF20222B)
              : Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF383C4A) : colors.borderDark,
              width: AppTheme.borderWidth,
            ),
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          notchMargin: 6.0,
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          color: isDark
              ? const Color(0xFF20222B)
              : Theme.of(context).scaffoldBackgroundColor,
          shape: const CircularNotchedRectangle(),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Row(
                children: [
                  // Left Wing (balanced 50% width minus center notch gap)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ShellNavItem(
                            key: const Key('nav_item_home'),
                            icon: Icons.home_rounded,
                            label: 'Home',
                            isSelected: currentIndex == 0,
                            onTap: () => _onTabSelected(0),
                          ),
                        ),
                        Expanded(
                          child: _ShellNavItem(
                            key: const Key('nav_item_approvals'),
                            icon: Icons.rule_rounded,
                            label: 'Approvals',
                            isSelected: currentIndex == 1,
                            onTap: () => _onTabSelected(1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center notch gap: Mathematically centered at exactly 50%
                  const SizedBox(width: 72),

                  // Right Wing (balanced 50% width minus center notch gap)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ShellNavItem(
                            key: const Key('nav_item_cards'),
                            icon: Icons.credit_card_rounded,
                            label: 'Cards',
                            isSelected: currentIndex == 2,
                            onTap: () => _onTabSelected(2),
                          ),
                        ),
                        Expanded(
                          child: _ShellNavItem(
                            key: const Key('nav_item_insights'),
                            icon: Icons.insights_rounded,
                            label: 'Insights',
                            isSelected: currentIndex == 3,
                            onTap: () => _onTabSelected(3),
                          ),
                        ),
                        Expanded(
                          child: _ShellNavItem(
                            key: const Key('nav_item_profile'),
                            icon: Icons.person_rounded,
                            label: 'Profile',
                            isSelected: currentIndex == 4,
                            onTap: () => _onTabSelected(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stylized Pastel Flat individual navigation tab.
class _ShellNavItem extends StatelessWidget {
  const _ShellNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark
        ? colors.mint.withValues(alpha: 0.22)
        : colors.mint;
    final selectedBorder = isDark
        ? Border.all(color: colors.mint, width: 1.5)
        : Border.all(color: colors.borderDark, width: AppTheme.borderWidth);
    final activeIconColor = isDark ? colors.mint : const Color(0xFF1A1C1E);
    final inactiveIconColor =
        isDark ? const Color(0xFFB0B9B4) : const Color(0xFF5E6764);
    final activeTextColor = isDark ? colors.mint : const Color(0xFF1A1C1E);
    final inactiveTextColor =
        isDark ? const Color(0xFFCBD5D0) : const Color(0xFF5E6764);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 44 : 36,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? selectedBorder : null,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? activeIconColor : inactiveIconColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.labelMd.copyWith(
                fontSize: 10.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeTextColor : inactiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
