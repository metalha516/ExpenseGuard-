import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_guard/features/home/presentation/main_shell.dart';
import 'package:expense_guard/features/onboarding/presentation/onboarding_screen.dart';
import 'package:expense_guard/features/auth/presentation/login_screen.dart';
import 'package:expense_guard/features/home/presentation/home_screen.dart';
import 'package:expense_guard/features/expenses/presentation/submit_expense_screen.dart';
import 'package:expense_guard/features/expenses/presentation/expense_review_screen.dart';
import 'package:expense_guard/features/expenses/presentation/policy_check_screen.dart';
import 'package:expense_guard/features/expenses/presentation/transaction_detail_screen.dart';
import 'package:expense_guard/features/cards/presentation/corporate_cards_screen.dart';
import 'package:expense_guard/features/approvals/presentation/approvals_queue_screen.dart';
import 'package:expense_guard/features/insights/presentation/spend_insights_screen.dart';
import 'package:expense_guard/features/notifications/presentation/notifications_center_screen.dart';
import 'package:expense_guard/features/profile/presentation/profile_settings_screen.dart';

/// Creates a smooth fade-and-subtle-slide page transition matching Pastel Flat aesthetic.
CustomTransitionPage<void> buildSmoothPageTransition({
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 280),
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Factory creating a fresh GoRouter instance for ExpenseGuard.
GoRouter createAppRouter({
  String initialLocation = '/onboarding',
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  final rootKey = navigatorKey ?? GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    routes: [
      // 1. Onboarding Screen (Initial route)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildSmoothPageTransition(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      // 2. Login Screen
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildSmoothPageTransition(
          state: state,
          child: const LoginScreen(),
        ),
      ),

      // 3 - 7: MainShell with persistent 5-tab navigation bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: Approvals Queue
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/approvals',
                builder: (context, state) => const ApprovalsQueueScreen(),
              ),
            ],
          ),

          // Tab 2: Corporate Cards
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cards',
                builder: (context, state) => const CorporateCardsScreen(),
              ),
            ],
          ),

          // Tab 3: Spend Insights
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const SpendInsightsScreen(),
              ),
            ],
          ),

          // Tab 4: Profile & Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileSettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // 8. Submit Expense / Camera flow (triggered by docked center FAB)
      GoRoute(
        path: '/submit-expense',
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => buildSmoothPageTransition(
          state: state,
          child: const SubmitExpenseScreen(),
        ),
      ),

      // 9. Expense Review Screen
      GoRoute(
        path: '/expense-review',
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) {
          final imagePath =
              state.extra as String? ?? state.uri.queryParameters['imagePath'];
          return buildSmoothPageTransition(
            state: state,
            child: ExpenseReviewScreen(imagePath: imagePath),
          );
        },
      ),

      // 10. Policy Check Screen
      GoRoute(
        path: '/policy-check',
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => buildSmoothPageTransition(
          state: state,
          child: const PolicyCheckScreen(),
        ),
      ),

      // 11. Transaction Detail Screen
      GoRoute(
        path: '/transaction-detail',
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? (state.extra as String?);
          final heroTag = state.uri.queryParameters['heroTag'];
          return buildSmoothPageTransition(
            state: state,
            child: TransactionDetailScreen(
              transactionId: id,
              heroTag: heroTag,
            ),
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: rootKey,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ??
                  state.uri.queryParameters['id'] ??
                  (state.extra as String?);
              final heroTag = state.uri.queryParameters['heroTag'];
              return buildSmoothPageTransition(
                state: state,
                child: TransactionDetailScreen(
                  transactionId: id,
                  heroTag: heroTag,
                ),
              );
            },
          ),
        ],
      ),

      // 12. Notifications Center Screen
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => buildSmoothPageTransition(
          state: state,
          child: const NotificationsCenterScreen(),
        ),
      ),
    ],
  );
}

/// Default global router instance.
final appRouter = createAppRouter();

/// Riverpod provider exposing fresh router configuration per scope.
final routerProvider = Provider<GoRouter>((ref) => createAppRouter());
