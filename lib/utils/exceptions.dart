// Custom exception classes for better error handling

abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class OfflineException extends AppException {
  OfflineException(String message) : super(message, code: 'offline');
}

class AuthException extends AppException {
  AuthException(String message) : super(message, code: 'auth');
}

class DataException extends AppException {
  DataException(String message) : super(message, code: 'data');
}

class FirestoreException extends AppException {
  FirestoreException(String message) : super(message, code: 'firestore');
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'network');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'validation');
}

// Helper class for handling exceptions in UI
class ExceptionHandler {
  static String getDisplayMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is Exception) {
      return error.toString();
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static bool isOfflineError(dynamic error) {
    return error is OfflineException ||
        (error.toString().contains('unavailable')) ||
        (error.toString().contains('offline')) ||
        (error.toString().contains('timeout'));
  }

  static bool isAuthError(dynamic error) {
    return error is AuthException ||
        error.toString().contains('permission-denied') ||
        error.toString().contains('unauthenticated');
  }
}
