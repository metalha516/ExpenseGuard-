import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/shared/presentation/skeleton_loader.dart';
import 'package:expense_guard/features/home/presentation/home_screen.dart';
import 'package:expense_guard/features/home/providers/home_provider.dart';
import 'package:expense_guard/features/approvals/presentation/approvals_screen.dart';
import 'package:expense_guard/features/approvals/providers/approvals_provider.dart';
import 'package:expense_guard/features/cards/presentation/cards_screen.dart';
import 'package:expense_guard/features/cards/providers/cards_provider.dart';
import 'package:expense_guard/features/insights/presentation/insights_screen.dart';
import 'package:expense_guard/features/insights/providers/insights_provider.dart';
import 'package:expense_guard/features/notifications/presentation/notifications_screen.dart';
import 'package:expense_guard/features/notifications/providers/notifications_provider.dart';

class LoadingHomeNotifier extends HomeNotifier {
  @override
  HomeState build() => super.build().copyWith(isLoading: true);
}

class LoadingApprovalsNotifier extends ApprovalsNotifier {
  @override
  ApprovalsState build() => super.build().copyWith(isLoading: true);
}

class LoadingCardsNotifier extends CardsNotifier {
  @override
  CardsState build() => super.build().copyWith(isLoading: true);
}

class LoadingInsightsNotifier extends InsightsNotifier {
  @override
  InsightsState build() => super.build().copyWith(isLoading: true);
}

class LoadingNotificationsNotifier extends NotificationsNotifier {
  @override
  NotificationsState build() => super.build().copyWith(isLoading: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Skeleton Component Unit & Widget Tests', () {
    testWidgets('PastelShimmer and SkeletonBox render with custom dimensions and border',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: PastelShimmer(
              key: Key('test_shimmer'),
              child: SkeletonBox(
                key: Key('test_box'),
                width: 150,
                height: 45,
                borderRadius: 12,
                hasBorder: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_shimmer')), findsOneWidget);
      expect(find.byKey(const Key('test_box')), findsOneWidget);

      final box = tester.widget<SkeletonBox>(find.byKey(const Key('test_box')));
      expect(box.width, 150);
      expect(box.height, 45);
      expect(box.borderRadius, 12);
      expect(box.hasBorder, isTrue);
    });

    testWidgets('HomeSkeletonLoader renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HomeSkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(HomeSkeletonLoader), findsOneWidget);
    });

    testWidgets('CardsSkeletonLoader renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CardsSkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(CardsSkeletonLoader), findsOneWidget);
    });

    testWidgets('ApprovalsSkeletonLoader renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ApprovalsSkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(ApprovalsSkeletonLoader), findsOneWidget);
    });

    testWidgets('InsightsSkeletonLoader renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: InsightsSkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(InsightsSkeletonLoader), findsOneWidget);
    });

    testWidgets('NotificationsSkeletonLoader renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: NotificationsSkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(NotificationsSkeletonLoader), findsOneWidget);
    });
  });

  group('Screen Skeleton Loading Integration Tests', () {
    testWidgets('HomeScreen renders HomeSkeletonLoader when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeStateProvider.overrideWith(LoadingHomeNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      // Verify skeleton loader is present and normal content is deferred
      expect(find.byKey(const Key('home_skeleton_loader')), findsOneWidget);
      expect(find.text('Total spend this month'), findsNothing);
    });

    testWidgets('ApprovalsScreen renders ApprovalsSkeletonLoader when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            approvalsProvider.overrideWith(LoadingApprovalsNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ApprovalsScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key('approvals_skeleton_loader')), findsOneWidget);
    });

    testWidgets('CardsScreen renders CardsSkeletonLoader when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(LoadingCardsNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CardsScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key('cards_skeleton_loader')), findsOneWidget);
      expect(find.text('Your Cards'), findsNothing);
    });

    testWidgets('InsightsScreen renders InsightsSkeletonLoader when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(LoadingInsightsNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const InsightsScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key('insights_skeleton_loader')), findsOneWidget);
      expect(find.text('Budget Health'), findsNothing);
    });

    testWidgets('NotificationsScreen renders NotificationsSkeletonLoader when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider.overrideWith(LoadingNotificationsNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NotificationsScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key('notifications_skeleton_loader')), findsOneWidget);
    });
  });
}
