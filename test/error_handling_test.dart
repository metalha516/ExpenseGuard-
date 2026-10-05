import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_guard/core/errors/app_error_handler.dart';
import 'package:expense_guard/core/errors/app_error_boundary.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkException Unit Tests', () {
    test('default message is provided when none is passed', () {
      const exception = NetworkException();
      expect(exception.message, contains('Network connection failed'));
      expect(exception.toString(), contains('Network connection failed'));
    });

    test('custom message is preserved and returned by toString()', () {
      const exception = NetworkException('Unable to reach server. Error 503.');
      expect(exception.message, 'Unable to reach server. Error 503.');
      expect(exception.toString(), 'Unable to reach server. Error 503.');
    });
  });

  group('AppErrorHandler Snackbar Tests', () {
    testWidgets('showErrorSnackbar displays pastel red container, title, message, and retry button',
        (WidgetTester tester) async {
      bool retryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('trigger_error_btn'),
                onPressed: () {
                  AppErrorHandler.showErrorSnackbar(
                    context,
                    message: 'Simulated connection failure during sync',
                    actionLabel: 'Retry Sync',
                    onRetry: () {
                      retryClicked = true;
                    },
                  );
                },
                child: const Text('Trigger Error'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show error snackbar
      await tester.tap(find.byKey(const Key('trigger_error_btn')));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 300)); // Animate in

      expect(find.byKey(const Key('global_error_snackbar')), findsOneWidget);
      expect(find.text('Connection Error'), findsOneWidget);
      expect(find.text('Simulated connection failure during sync'), findsOneWidget);
      expect(find.text('Retry Sync'), findsOneWidget);

      // Tap Retry button
      await tester.tap(find.byKey(const Key('error_snackbar_retry_button')));
      await tester.pumpAndSettle();

      expect(retryClicked, isTrue);
    });

    testWidgets('showErrorSnackbar works without onRetry action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('trigger_no_retry_btn'),
                onPressed: () {
                  AppErrorHandler.showErrorSnackbar(
                    context,
                    message: 'Temporary glitch occurred',
                  );
                },
                child: const Text('Trigger Glitch'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('trigger_no_retry_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('global_error_snackbar')), findsOneWidget);
      expect(find.text('Temporary glitch occurred'), findsOneWidget);
      expect(find.byKey(const Key('error_snackbar_retry_button')), findsNothing);
    });

    testWidgets('showSuccessSnackbar displays pastel mint container with checkmark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('trigger_success_btn'),
                onPressed: () {
                  AppErrorHandler.showSuccessSnackbar(
                    context,
                    message: 'Expense successfully submitted for approval',
                  );
                },
                child: const Text('Trigger Success'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('trigger_success_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('global_success_snackbar')), findsOneWidget);
      expect(
        find.text('Expense successfully submitted for approval'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('AppErrorBoundary Widget Tests', () {
    testWidgets('renders child normally when there is no error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AppErrorBoundary(
            child: Text('Normal Screen Content', key: Key('child_content')),
          ),
        ),
      );

      expect(find.byKey(const Key('child_content')), findsOneWidget);
      expect(find.byKey(const Key('app_error_boundary_card')), findsNothing);
    });

    testWidgets('displays Pastel Flat error card when error is reported',
        (WidgetTester tester) async {
      Object? capturedError;
      bool onRetryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AppErrorBoundary(
            onError: (err, stack) {
              capturedError = err;
            },
            onRetry: () {
              onRetryCalled = true;
            },
            child: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('report_err_btn'),
                onPressed: () {
                  AppErrorBoundary.reportError(
                    context,
                    Exception('Widget build error occurred'),
                  );
                },
                child: const Text('Report Error'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('report_err_btn')), findsOneWidget);
      expect(find.byKey(const Key('app_error_boundary_card')), findsNothing);

      // Trigger error reporting
      await tester.tap(find.byKey(const Key('report_err_btn')));
      await tester.pumpAndSettle();

      // Verify Error Boundary UI is displayed
      expect(find.byKey(const Key('app_error_boundary_card')), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        find.text('We encountered an unexpected error while loading this screen. Please try again.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byKey(const Key('error_boundary_retry_button')), findsOneWidget);
      expect(capturedError, isNotNull);

      // Tap Retry button
      await tester.tap(find.byKey(const Key('error_boundary_retry_button')));
      await tester.pumpAndSettle();

      // UI should recover and show child again
      expect(onRetryCalled, isTrue);
      expect(find.byKey(const Key('report_err_btn')), findsOneWidget);
      expect(find.byKey(const Key('app_error_boundary_card')), findsNothing);
    });
  });
}
