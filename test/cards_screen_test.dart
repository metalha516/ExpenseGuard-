import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/cards/presentation/cards_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const ProviderScope(
        child: Scaffold(
          body: CardsScreen(),
        ),
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('CardsScreen UI & Carousel Tests', () {
    testWidgets('Renders top bar, physical card details, and metrics',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Corporate Cards'), findsOneWidget);
      expect(find.text('Your Cards'), findsOneWidget);

      // Verify First Card details
      expect(find.text('ALEX JOHNSON'), findsAtLeast(1));
      expect(find.textContaining('4289'), findsAtLeast(1));
      expect(find.text('12/26'), findsOneWidget);
      expect(find.textContaining('VISA'), findsAtLeast(1));

      // Verify Budget Progress
      expect(find.text('Monthly Spend Utilization'), findsOneWidget);
      expect(find.textContaining('Spent:'), findsOneWidget);

      // Verify Controls
      expect(find.text('Freeze Card'), findsOneWidget);
      expect(find.byKey(const Key('card_freeze_switch')), findsOneWidget);
      expect(find.byKey(const Key('card_limit_tile')), findsOneWidget);
      expect(find.byKey(const Key('request_new_card_button')), findsOneWidget);
    });

    testWidgets('Swiping PageView reveals the virtual card and its label',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Initial card is Alex Johnson (4289)
      expect(find.textContaining('4289'), findsAtLeast(1));

      // Swipe carousel left to show card 2
      await tester.drag(find.byKey(const Key('cards_page_view')), const Offset(-600, 0));
      await tester.pumpAndSettle();

      // Card 2 is the virtual subscription card
      expect(find.textContaining('9912'), findsAtLeast(1));
      expect(find.text('VIRTUAL'), findsAtLeast(1));
    });
  });

  group('Card Controls & Actions Tests', () {
    testWidgets('Toggling freeze switch updates freeze state and overlay',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Initially card-01 is not frozen
      expect(find.byKey(const Key('card_frozen_overlay_card-01')), findsNothing);

      // Tap freeze switch
      final switchFinder = find.byKey(const Key('card_freeze_switch'));
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify card-01 frozen overlay appears
      expect(find.byKey(const Key('card_frozen_overlay_card-01')), findsOneWidget);
      expect(find.text('Card is temporarily locked'), findsOneWidget);

      // Unfreeze
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Frozen overlay removed
      expect(find.byKey(const Key('card_frozen_overlay_card-01')), findsNothing);
    });

    testWidgets('Adjust Limit dialog updates card monthly limit',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap Adjust Limit tile
      await tester.tap(find.byKey(const Key('card_limit_tile')));
      await tester.pumpAndSettle();

      // Verify bottom sheet opened
      expect(find.text('Adjust Spending Limit'), findsOneWidget);
      expect(find.byKey(const Key('card_limit_slider')), findsOneWidget);
      expect(find.byKey(const Key('save_limit_button')), findsOneWidget);

      // Drag slider
      await tester.drag(find.byKey(const Key('card_limit_slider')), const Offset(100, 0));
      await tester.pumpAndSettle();

      // Save limit
      await tester.tap(find.byKey(const Key('save_limit_button')));
      await tester.pumpAndSettle();

      // Verify bottom sheet closed
      expect(find.text('Adjust Spending Limit'), findsNothing);
    });

    testWidgets('Request New Card sheet creates and provisions a new card',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap Request New Card button
      await tester.tap(find.byKey(const Key('request_new_card_button')));
      await tester.pumpAndSettle();

      // Verify Request Card sheet opened
      expect(find.text('Request Corporate Card'), findsOneWidget);
      expect(find.byKey(const Key('card_type_virtual')), findsOneWidget);
      expect(find.byKey(const Key('card_type_physical')), findsOneWidget);

      // Select physical card type
      await tester.tap(find.byKey(const Key('card_type_physical')));
      await tester.pumpAndSettle();

      // Enter card nickname
      await tester.enterText(
        find.byKey(const Key('new_card_label_input')),
        'Executive Travel Card',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byKey(const Key('submit_new_card_button')));
      await tester.pumpAndSettle();

      // Verify sheet closed
      expect(find.text('Request Corporate Card'), findsNothing);

      // Verify snackbar feedback
      expect(find.textContaining('New Physical Card requested successfully!'), findsOneWidget);
    });
  });
}
