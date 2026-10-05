import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_guard/core/router/scaffold_with_nav_bar.dart';
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
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 2. Login Screen
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 3 - 7: Persistent Bottom Navigation Shell Structure
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
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

          // Tab 1: Submit Expense / Camera
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/submit-expense',
                builder: (context, state) => const SubmitExpenseScreen(),
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

          // Tab 3: Approvals Queue
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/approvals',
                builder: (context, state) => const ApprovalsQueueScreen(),
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

      // 8. Expense Review Screen
      GoRoute(
        path: '/expense-review',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const ExpenseReviewScreen(),
      ),

      // 9. Policy Check Screen
      GoRoute(
        path: '/policy-check',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const PolicyCheckScreen(),
      ),

      // 10. Transaction Detail Screen
      GoRoute(
        path: '/transaction-detail',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return TransactionDetailScreen(transactionId: id);
        },
      ),

      // 11. Spend Insights Screen
      GoRoute(
        path: '/insights',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SpendInsightsScreen(),
      ),

      // 12. Notifications Center Screen
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const NotificationsCenterScreen(),
      ),
    ],
  );
}

/// Default global router instance.
final appRouter = createAppRouter();

/// Riverpod provider exposing fresh router configuration per scope.
final routerProvider = Provider<GoRouter>((ref) => createAppRouter());
