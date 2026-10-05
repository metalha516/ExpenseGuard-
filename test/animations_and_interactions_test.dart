import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_guard/main.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/core/router/app_router.dart';
import 'package:expense_guard/features/shared/presentation/animations/pastel_tap_scale.dart';
import 'package:expense_guard/features/home/presentation/home_screen.dart';
import 'package:expense_guard/features/approvals/presentation/approvals_screen.dart';
import 'package:expense_guard/features/expenses/presentation/transaction_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PastelTapScale Micro-interaction Widget Tests', () {
    testWidgets('renders child widget properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PastelTapScale(
              key: const Key('tap_scale_widget'),
              onTap: () {},
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('tap_scale_widget')), findsOneWidget);
      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('animates scale and opacity on pointer down/up and triggers onTap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PastelTapScale(
              key: const Key('tap_scale_widget'),
              scaleDown: 0.90,
              fadeDown: 0.85,
              duration: const Duration(milliseconds: 100),
              onTap: () {
                tapped = true;
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                key: const Key('inner_box'),
              ),
            ),
          ),
        ),
      );

      Transform getTransform() => tester.widget<Transform>(
            find.descendant(
              of: find.byType(PastelTapScale),
              matching: find.byType(Transform),
            ),
          );
      Opacity getOpacity() => tester.widget<Opacity>(
            find.descendant(
              of: find.byType(PastelTapScale),
              matching: find.byType(Opacity),
            ),
          );

      // Verify initial state: scale 1.0, opacity 1.0
      expect(getTransform().transform.storage[0], 1.0);

      // Press down (pointer down)
      final gesture = await tester.startGesture(tester.getCenter(find.byKey(const Key('inner_box'))));
      await tester.pump(); // Initialize ticker start time
      await tester.pump(const Duration(milliseconds: 100)); // Forward animation complete

      // Verify scaled down on 2D axes and faded
      expect(getTransform().transform.storage[0], closeTo(0.90, 0.01));
      expect(getTransform().transform.storage[5], closeTo(0.90, 0.01));
      expect(getOpacity().opacity, closeTo(0.85, 0.01));

      // Release (pointer up)
      await gesture.up();
      await tester.pump(); // Initialize reverse ticker
      await tester.pump(const Duration(milliseconds: 100)); // Reverse animation complete
      await tester.pumpAndSettle();

      // Verify returned to 1.0
      expect(getTransform().transform.storage[0], closeTo(1.0, 0.01));
      expect(getOpacity().opacity, closeTo(1.0, 0.01));
      expect(tapped, isTrue);
    });

    testWidgets('triggers onLongPress callback when held',
        (WidgetTester tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PastelTapScale(
              key: const Key('tap_scale_widget'),
              onLongPress: () {
                longPressed = true;
              },
              child: const Text('Hold Me'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Hold Me'));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });

    testWidgets('does not animate or intercept when enabled is false',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PastelTapScale(
              enabled: false,
              onTap: () {
                tapped = true;
              },
              child: const Text('Disabled Button'),
            ),
          ),
        ),
      );

      expect(find.text('Disabled Button'), findsOneWidget);
      // Transform shouldn't be added inside PastelTapScale when disabled
      expect(
        find.descendant(
          of: find.byType(PastelTapScale),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );

      await tester.tap(find.text('Disabled Button'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });
  });

  group('Hero Transition Integration Tests', () {
    testWidgets('HomeScreen contains receipt Hero widgets for recent transactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProviderScope(
            child: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Heroes on HomeScreen
      final heroes = find.byType(Hero);
      expect(heroes, findsWidgets);

      // Verify specific transaction hero tag exists
      final starbucksHeroFinder = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'receipt_hero_txn-101',
      );
      expect(starbucksHeroFinder, findsOneWidget);
    });

    testWidgets('ApprovalsScreen contains receipt Hero widgets for pending approval items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProviderScope(
            child: ApprovalsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Heroes on ApprovalsScreen
      final deltaHeroFinder = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'approval_hero_appr-01',
      );
      expect(deltaHeroFinder, findsOneWidget);
    });

    testWidgets('TransactionDetailScreen contains receipt Hero widget matching transaction id',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProviderScope(
            child: TransactionDetailScreen(transactionId: 'txn-101'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final detailHeroFinder = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'receipt_hero_txn-101',
      );
      expect(detailHeroFinder, findsOneWidget);
    });

    testWidgets('Full Hero flight navigates from HomeScreen to TransactionDetailScreen smoothly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Skip onboarding
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Tap Starbucks item on HomeScreen
      await tester.ensureVisible(find.text('Starbucks'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Starbucks'));

      // Pump mid-flight to confirm Hero transition animation is running without exceptions
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Hero), findsWidgets);

      // Settle Hero transition into TransactionDetailScreen
      await tester.pumpAndSettle();

      expect(find.text('Transaction Detail'), findsOneWidget);
      expect(find.text('Starbucks'), findsOneWidget);

      // Pop back to HomeScreen
      await tester.tap(find.byKey(const Key('transaction_detail_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Alex'), findsOneWidget);
    });

    testWidgets('Full Hero flight navigates from ApprovalsScreen to TransactionDetailScreen smoothly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Skip onboarding
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Switch to Approvals tab
      await tester.tap(find.byKey(const Key('nav_item_approvals')));
      await tester.pumpAndSettle();

      // Tap first approval card (Alex Johnson / Delta Airlines -> txn-101)
      await tester.tap(find.byKey(const Key('approval_card_appr-01')));

      // Mid-flight verification
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Hero), findsWidgets);

      // Finish transition
      await tester.pumpAndSettle();

      expect(find.text('Transaction Detail'), findsOneWidget);

      // Pop back to ApprovalsScreen
      await tester.tap(find.byKey(const Key('transaction_detail_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Approvals Queue'), findsOneWidget);
    });
  });

  group('Page Transitions Theme & Router Tests', () {
    test('AppTheme light and dark configure ZoomPageTransitionsBuilder across platforms', () {
      final lightBuilders = AppTheme.lightTheme.pageTransitionsTheme.builders;
      expect(lightBuilders[TargetPlatform.android], isA<ZoomPageTransitionsBuilder>());
      expect(lightBuilders[TargetPlatform.iOS], isA<ZoomPageTransitionsBuilder>());
      expect(lightBuilders[TargetPlatform.windows], isA<ZoomPageTransitionsBuilder>());
      expect(lightBuilders[TargetPlatform.macOS], isA<ZoomPageTransitionsBuilder>());
      expect(lightBuilders[TargetPlatform.linux], isA<ZoomPageTransitionsBuilder>());

      final darkBuilders = AppTheme.darkTheme.pageTransitionsTheme.builders;
      expect(darkBuilders[TargetPlatform.android], isA<ZoomPageTransitionsBuilder>());
      expect(darkBuilders[TargetPlatform.iOS], isA<ZoomPageTransitionsBuilder>());
      expect(darkBuilders[TargetPlatform.windows], isA<ZoomPageTransitionsBuilder>());
      expect(darkBuilders[TargetPlatform.macOS], isA<ZoomPageTransitionsBuilder>());
      expect(darkBuilders[TargetPlatform.linux], isA<ZoomPageTransitionsBuilder>());
    });

    test('createAppRouter creates router with custom page routes', () {
      final router = createAppRouter();
      expect(router, isA<GoRouter>());
      expect(router.configuration.routes.length, greaterThan(3));
    });

    testWidgets('pushed routes animate smoothly via GoRouter custom transition',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Skip onboarding to go to HomeScreen
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Open Notifications screen via bell icon
      await tester.tap(find.byKey(const Key('home_notifications_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 140));

      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);

      // Settle transition
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
    });
  });
}
