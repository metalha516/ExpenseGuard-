import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/notifications/presentation/notifications_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const ProviderScope(
        child: Scaffold(
          body: NotificationsScreen(),
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

  group('NotificationsScreen UI & Grouping Tests', () {
    testWidgets('Renders header, unread badge, and groups (Today, Yesterday, Earlier)',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byKey(const Key('header_unread_badge')), findsOneWidget);
      expect(find.text('3 new'), findsOneWidget);

      // Verify Mark Read Button
      expect(find.byKey(const Key('mark_all_read_button')), findsOneWidget);

      // Verify Group Headers
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.text('EARLIER'), findsOneWidget);

      // Verify Items in Groups
      expect(find.text('Alex approved your travel expense'), findsOneWidget);
      expect(find.text('Policy Alert: Duplicate claim detected'), findsOneWidget);
      expect(find.text('Monthly spend summary is ready'), findsOneWidget);
      expect(find.text('Card Limit Warning: 80% Reached'), findsOneWidget);

      // Verify Unread Dots
      expect(find.byKey(const Key('unread_indicator_notif-01')), findsOneWidget);
      expect(find.byKey(const Key('unread_indicator_notif-02')), findsOneWidget);
      expect(find.byKey(const Key('unread_indicator_notif-03')), findsNothing);
    });

    testWidgets('Tapping Mark All Read marks all items as read and clears badges',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap Mark all read
      await tester.tap(find.byKey(const Key('mark_all_read_button')));
      await tester.pumpAndSettle();

      // Badges cleared
      expect(find.byKey(const Key('header_unread_badge')), findsNothing);
      expect(find.byKey(const Key('mark_all_read_button')), findsNothing);
      expect(find.byKey(const Key('unread_indicator_notif-01')), findsNothing);
      expect(find.byKey(const Key('unread_indicator_notif-02')), findsNothing);

      // Feedback snackbar shown
      expect(find.text('All notifications marked as read'), findsOneWidget);
    });

    testWidgets('Tapping a single unread card marks it as read',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // notif-01 is unread initially
      expect(find.byKey(const Key('unread_indicator_notif-01')), findsOneWidget);
      expect(find.text('3 new'), findsOneWidget);

      // Tap card
      await tester.tap(find.byKey(const Key('card_tap_notif-01')));
      await tester.pumpAndSettle();

      // notif-01 unread dot removed, count decreased to 2 new
      expect(find.byKey(const Key('unread_indicator_notif-01')), findsNothing);
      expect(find.text('2 new'), findsOneWidget);
    });
  });

  group('NotificationsScreen Filters & Actions Tests', () {
    testWidgets('Filter chips filter visible items properly',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap Unread filter
      await tester.tap(find.byKey(const Key('filter_unread')));
      await tester.pumpAndSettle();

      // Unread items visible
      expect(find.text('Alex approved your travel expense'), findsOneWidget);
      expect(find.text('Policy Alert: Duplicate claim detected'), findsOneWidget);
      // Read item should not be visible
      expect(find.text('Monthly spend summary is ready'), findsNothing);

      // Tap Alerts filter
      await tester.tap(find.byKey(const Key('filter_alerts')));
      await tester.pumpAndSettle();

      expect(find.text('Policy Alert: Duplicate claim detected'), findsOneWidget);
      expect(find.text('Card Limit Warning: 80% Reached'), findsOneWidget);
      expect(find.text('Alex approved your travel expense'), findsNothing);

      // Tap All filter to restore
      await tester.tap(find.byKey(const Key('filter_all')));
      await tester.pumpAndSettle();

      expect(find.text('Alex approved your travel expense'), findsOneWidget);
      expect(find.text('Monthly spend summary is ready'), findsOneWidget);
    });

    testWidgets('Search input filters notifications by title/message',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byKey(const Key('toggle_search_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('notifications_search_input')), findsOneWidget);

      // Type query
      await tester.enterText(
        find.byKey(const Key('notifications_search_input')),
        'Duplicate',
      );
      await tester.pumpAndSettle();

      expect(find.text('Policy Alert: Duplicate claim detected'), findsOneWidget);
      expect(find.text('Alex approved your travel expense'), findsNothing);
    });

    testWidgets('Dismissible swiping removes notification item',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Swipe notif-01 to delete
      await tester.drag(find.byKey(const Key('dismiss_notif-01')), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify item removed from list
      expect(find.text('Alex approved your travel expense'), findsNothing);
      expect(find.textContaining('Dismissed: Alex approved your travel expense'), findsOneWidget);
    });
  });
}
