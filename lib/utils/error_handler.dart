import 'package:flutter/material.dart';
import 'exceptions.dart';
import '../widgets/offline_banner.dart';

class ErrorHandler {
  /// Executes an async operation with proper error handling and user feedback
  static Future<T?> handleAsync<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    bool showOfflineSnackbar = true,
    bool showErrorSnackbar = true,
    VoidCallback? onRetry,
  }) async {
    try {
      final result = await operation();

      if (successMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(successMessage),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      return result;
    } on OfflineException catch (e) {
      if (showOfflineSnackbar && context.mounted) {
        OfflineSnackbar.show(context, e.message);
      }
      return null;
    } on AppException catch (e) {
      if (showErrorSnackbar && context.mounted) {
        ErrorSnackbar.show(
          context,
          e.message,
          onRetry: onRetry,
          isOffline: e is OfflineException,
        );
      }
      return null;
    } catch (e) {
      if (showErrorSnackbar && context.mounted) {
        ErrorSnackbar.show(
          context,
          'An unexpected error occurred. Please try again.',
          onRetry: onRetry,
        );
      }
      return null;
    }
  }

  /// Wrapper for UI actions that might fail
  static Future<void> safeAction(
    BuildContext context,
    Future<void> Function() action, {
    String? successMessage,
    VoidCallback? onRetry,
  }) async {
    await handleAsync(
      context,
      action,
      successMessage: successMessage,
      onRetry: onRetry,
    );
  }

  /// Show appropriate error message based on exception type
  static void showError(BuildContext context, dynamic error) {
    final message = ExceptionHandler.getDisplayMessage(error);
    final isOffline = ExceptionHandler.isOfflineError(error);

    if (isOffline) {
      OfflineSnackbar.show(context, message);
    } else {
      ErrorSnackbar.show(context, message, isOffline: false);
    }
  }
}

// Mixin for screens that need error handling
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  Future<R?> handleError<R>(
    Future<R> Function() operation, {
    String? successMessage,
    VoidCallback? onRetry,
  }) async {
    return ErrorHandler.handleAsync(
      context,
      operation,
      successMessage: successMessage,
      onRetry: onRetry,
    );
  }

  void showError(dynamic error) {
    ErrorHandler.showError(context, error);
  }

  Future<void> safeAction(
    Future<void> Function() action, {
    String? successMessage,
    VoidCallback? onRetry,
  }) async {
    await ErrorHandler.safeAction(
      context,
      action,
      successMessage: successMessage,
      onRetry: onRetry,
    );
  }
}
