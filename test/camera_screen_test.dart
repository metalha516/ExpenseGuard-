import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_guard/main.dart';
import 'package:expense_guard/features/expenses/presentation/submit_expense_camera_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SubmitExpenseCameraScreen renders viewfinder overlay, guidelines, and controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Skip onboarding
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Tap docked camera FAB to open Camera Screen
    await tester.tap(find.byKey(const Key('docked_camera_fab')));
    await tester.pumpAndSettle();

    // Verify SubmitExpenseCameraScreen is mounted
    expect(find.byType(SubmitExpenseCameraScreen), findsOneWidget);

    // 1. Verify Top Controls
    expect(find.byKey(const Key('camera_close_button')), findsOneWidget);
    expect(find.byKey(const Key('camera_auto_capture_toggle')), findsOneWidget);
    expect(find.byKey(const Key('camera_flash_toggle_button')), findsOneWidget);

    // 2. Verify Instructional text & Mode pills
    expect(find.text('Position receipt within the frame'), findsOneWidget);
    expect(find.text('Receipt'), findsOneWidget);
    expect(find.text('Multiple'), findsOneWidget);

    // 3. Verify Bottom Shutter & Picker Controls
    expect(find.byKey(const Key('camera_gallery_picker_button')), findsOneWidget);
    expect(find.byKey(const Key('camera_shutter_button')), findsOneWidget);
    expect(find.byKey(const Key('camera_manual_entry_button')), findsOneWidget);
  });

  testWidgets('Tapping Flash and Auto-capture toggles their respective states',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Skip onboarding
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Open Camera
    await tester.tap(find.byKey(const Key('docked_camera_fab')));
    await tester.pumpAndSettle();

    // 1. Toggle Flash
    expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
    await tester.tap(find.byKey(const Key('camera_flash_toggle_button')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);

    // 2. Toggle Auto-capture
    expect(find.text('Auto-capture ON'), findsOneWidget);
    await tester.tap(find.byKey(const Key('camera_auto_capture_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Auto-capture OFF'), findsOneWidget);
  });

  testWidgets('Tapping Shutter button captures receipt and navigates to Expense Review',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Skip onboarding
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Open Camera
    await tester.tap(find.byKey(const Key('docked_camera_fab')));
    await tester.pumpAndSettle();

    // Tap Shutter Button
    await tester.tap(find.byKey(const Key('camera_shutter_button')));
    await tester.pumpAndSettle();

    // Verify navigation to Expense Review Screen
    expect(find.text('Expense Review'), findsOneWidget);
    expect(find.text('Review & Edit Details'), findsOneWidget);
  });

  testWidgets('Tapping Close button dismisses camera viewfinder',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Skip onboarding
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Open Camera
    await tester.tap(find.byKey(const Key('docked_camera_fab')));
    await tester.pumpAndSettle();
    expect(find.byType(SubmitExpenseCameraScreen), findsOneWidget);

    // Tap Close Button
    await tester.tap(find.byKey(const Key('camera_close_button')));
    await tester.pumpAndSettle();

    // Verify returned to HomeScreen
    expect(find.byType(SubmitExpenseCameraScreen), findsNothing);
    expect(find.text('Good morning, Alex'), findsOneWidget);
  });
}
