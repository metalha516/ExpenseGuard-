import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

/// Persistent shell scaffold containing the Pastel Flat bottom navigation bar.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell and container for the branch being displayed.
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when tapping the current tab is to pop to the root
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
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
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: 16,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => _onTap(0),
              ),
              _NavBarItem(
                icon: Icons.add_circle_rounded,
                label: 'Submit',
                isSelected: currentIndex == 1,
                onTap: () => _onTap(1),
              ),
              _NavBarItem(
                icon: Icons.credit_card_rounded,
                label: 'Cards',
                isSelected: currentIndex == 2,
                onTap: () => _onTap(2),
              ),
              _NavBarItem(
                icon: Icons.rule_rounded,
                label: 'Approvals',
                isSelected: currentIndex == 3,
                onTap: () => _onTap(3),
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == 4,
                onTap: () => _onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool fearsSelectionDisabled = false;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? colors.mint : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(
                        color: colors.borderDark,
                        width: AppTheme.borderWidth,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? const Color(0xFF1A1C1E)
                    : (isDark ? Colors.white70 : const Color(0xFF5E6764)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.labelMd.copyWith(
                fontSize: 11,
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
