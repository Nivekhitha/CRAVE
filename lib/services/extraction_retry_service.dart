import 'dart:math';
import 'package:flutter/foundation.dart';

/// Service for handling extraction retries with exponential backoff
class ExtractionRetryService {
  static const int _maxRetries = 4;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const double _backoffMultiplier = 2.0;
  static const Duration _maxDelay = Duration(seconds: 16);

  /// Execute a function with exponential backoff retry logic
  /// Returns the result of the function or throws the last exception
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    Duration baseDelay = _baseDelay,
    bool Function(dynamic error)? shouldRetry,
    void Function(int attempt, dynamic error, Duration nextDelay)? onRetry,
  }) async {
    int attempt = 0;
    dynamic lastError;

    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        attempt++;

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          debugPrint("❌ Non-retryable error: $error");
          rethrow;
        }

        // If we've exhausted retries, throw the last error
        if (attempt > maxRetries) {
          debugPrint("❌ Max retries ($maxRetries) exceeded. Last error: $error");
          rethrow;
        }

        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(attempt, baseDelay);
        
        debugPrint("🔄 Retry attempt $attempt/$maxRetries after ${delay.inSeconds}s. Error: $error");
        
        // Notify callback
        onRetry?.call(attempt, error, delay);

        // Wait before retrying
        await Future.delayed(delay);
      }
    }

    // This should never be reached, but just in case
    throw lastError ?? Exception('Unknown error during retry operation');
  }

  /// Calculate delay with exponential backoff and jitter
  static Duration _calculateDelay(int attempt, Duration baseDelay) {
    // Exponential backoff: baseDelay * (backoffMultiplier ^ (attempt - 1))
    final exponentialDelay = baseDelay.inMilliseconds * 
        pow(_backoffMultiplier, attempt - 1).toInt();
    
    // Add jitter (±25% randomness) to avoid thundering herd
    final jitter = Random().nextDouble() * 0.5 + 0.75; // 0.75 to 1.25
    final delayWithJitter = (exponentialDelay * jitter).toInt();
    
    // Cap at maximum delay
    final cappedDelay = Duration(
      milliseconds: min(delayWithJitter, _maxDelay.inMilliseconds)
    );
    
    return cappedDelay;
  }

  /// Check if an error is retryable
  static bool isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Network errors - retryable
    if (errorString.contains('socketexception') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('network')) {
      return true;
    }
    
    // API quota/rate limiting - retryable
    if (errorString.contains('quota') ||
        errorString.contains('429') ||
        errorString.contains('rate limit')) {
      return true;
    }
    
    // Server errors (5xx) - retryable
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504')) {
      return true;
    }
    
    // Temporary AI service issues - retryable
    if (errorString.contains('service unavailable') ||
        errorString.contains('temporarily unavailable') ||
        errorString.contains('try again')) {
      return true;
    }
    
    // Non-retryable errors
    if (errorString.contains('api key') ||
        errorString.contains('invalid') ||
        errorString.contains('unauthorized') ||
        errorString.contains('403') ||
        errorString.contains('404') ||
        errorString.contains('malformed')) {
      return false;
    }
    
    // Default to retryable for unknown errors
    return true;
  }

  /// Get user-friendly error message
  static String getFriendlyErrorMessage(dynamic error, int attemptsMade) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('api key')) {
      return 'API key issue. Please check your configuration.';
    }
    
    if (errorString.contains('quota') || errorString.contains('429')) {
      return 'Service is busy. We tried $attemptsMade times but couldn\'t complete the extraction.';
    }
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network connection issue. Please check your internet and try again.';
    }
    
    if (errorString.contains('timeout')) {
      return 'The extraction took too long. This might be a large document - try breaking it into smaller parts.';
    }
    
    if (errorString.contains('no text found') || errorString.contains('too short')) {
      return 'Could not find readable text in the document. Make sure it contains recipe content.';
    }
    
    if (errorString.contains('no recipes found')) {
      return 'No recipes were found in the document. The content might not contain recipe information.';
    }
    
    // Generic friendly message
    return 'Extraction failed after $attemptsMade attempts. Please try again or contact support if the issue persists.';
  }

  /// Create a retry configuration for different extraction types
  static Map<String, dynamic> getRetryConfig(String extractionType) {
    switch (extractionType.toLowerCase()) {
      case 'pdf':
      case 'cookbook':
        return {
          'maxRetries': 3,
          'baseDelay': const Duration(seconds: 2),
          'description': 'PDF extraction with moderate retry',
        };
      
      case 'url':
      case 'instagram':
        return {
          'maxRetries': 2,
          'baseDelay': const Duration(seconds: 1),
          'description': 'URL extraction with quick retry',
        };
      
      case 'ai':
      case 'gemini':
        return {
          'maxRetries': 4,
          'baseDelay': const Duration(seconds: 1),
          'description': 'AI service with aggressive retry',
        };
      
      default:
        return {
          'maxRetries': _maxRetries,
          'baseDelay': _baseDelay,
          'description': 'Default retry configuration',
        };
    }
  }
}