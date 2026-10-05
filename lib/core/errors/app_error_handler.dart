import 'package:flutter/material.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

/// Custom exception representing simulated or real network failures.
class NetworkException implements Exception {
  const NetworkException([this.message = 'Network connection failed. Please check your internet connection.']);
  final String message;

  @override
  String toString() => message;
}

/// Global error handler rendering Pastel Flat neo-brutalist error snackbars and banners.
class AppErrorHandler {
  AppErrorHandler._();

  /// Global navigator key for contexts where context is not immediately available.
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Shows a styled Pastel Flat error snackbar.
  static void showErrorSnackbar(
    BuildContext context, {
    required String message,
    String? actionLabel = 'Retry',
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colors = context.pastelColors;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('global_error_snackbar'),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppTheme.marginMobile),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFEAEA), // Soft pastel red
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: colors.borderDark, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colors.borderDark.withValues(alpha: 0.15),
                offset: const Offset(3, 4),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD5D5),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.borderDark, width: 1.0),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFC62828),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Error',
                      style: context.labelMd.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.borderDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: context.metadataText.copyWith(
                        color: colors.borderDark.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  key: const Key('error_snackbar_retry_button'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onRetry();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colors.borderDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel ?? 'Retry',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a success snackbar matching Pastel Flat aesthetic.
  static void showSuccessSnackbar(
    BuildContext context, {
    required String message,
  }) {
    final colors = context.pastelColors;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('global_success_snackbar'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppTheme.marginMobile),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          decoration: BoxDecoration(
            color: colors.mint,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: colors.borderDark, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colors.borderDark.withValues(alpha: 0.12),
                offset: const Offset(3, 4),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: colors.primarySage,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.borderDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
