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
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          key: const Key('docked_camera_fab'),
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: colors.mint,
          foregroundColor: colors.borderDark,
          shape: CircleBorder(
            side: BorderSide(
              color: colors.borderDark,
              width: 2.0,
            ),
          ),
          onPressed: () => context.push('/submit-expense'),
          tooltip: 'Submit Expense (Camera)',
          child: Icon(
            Icons.camera_alt_rounded,
            size: 28,
            color: colors.borderDark,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: colors.borderDark,
              width: AppTheme.borderWidth,
            ),
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          notchMargin: 8.0,
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: const CircularNotchedRectangle(),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Left Tab 0: Home
                  Expanded(
                    child: _ShellNavItem(
                      key: const Key('nav_item_home'),
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      onTap: () => _onTabSelected(0),
                    ),
                  ),

                  // Left Tab 1: Approvals
                  Expanded(
                    child: _ShellNavItem(
                      key: const Key('nav_item_approvals'),
                      icon: Icons.rule_rounded,
                      label: 'Approvals',
                      isSelected: currentIndex == 1,
                      onTap: () => _onTabSelected(1),
                    ),
                  ),

                  // Center space reserved for the docked FAB
                  const SizedBox(width: 64),

                  // Right Tab 2: Cards
                  Expanded(
                    child: _ShellNavItem(
                      key: const Key('nav_item_cards'),
                      icon: Icons.credit_card_rounded,
                      label: 'Cards',
                      isSelected: currentIndex == 2,
                      onTap: () => _onTabSelected(2),
                    ),
                  ),

                  // Right Tab 3: Insights
                  Expanded(
                    child: _ShellNavItem(
                      key: const Key('nav_item_insights'),
                      icon: Icons.insights_rounded,
                      label: 'Insights',
                      isSelected: currentIndex == 3,
                      onTap: () => _onTabSelected(3),
                    ),
                  ),

                  // Right Tab 4: Profile
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 48 : 36,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? colors.mint : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(
                        color: colors.borderDark,
                        width: AppTheme.borderWidth,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF1A1C1E)
                    : (isDark ? Colors.white70 : const Color(0xFF5E6764)),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.labelMd.copyWith(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF1A1C1E))
                    : (isDark ? Colors.white60 : const Color(0xFF5E6764)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
