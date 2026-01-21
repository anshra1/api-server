import 'dart:math';

import 'package:dio/dio.dart';

/// Configuration for retry behavior with exponential backoff.
///
/// Example usage:
/// ```dart
/// final policy = RetryPolicy(
///   maxRetries: 3,
///   initialDelay: Duration(milliseconds: 500),
/// );
/// ```
class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryableExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ],
  });

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Initial delay before first retry
  final Duration initialDelay;

  /// Maximum delay cap (prevents very long waits)
  final Duration maxDelay;

  /// Multiplier for exponential backoff (e.g., 2.0 = double each time)
  final double backoffMultiplier;

  /// HTTP status codes that should trigger a retry
  final List<int> retryableStatusCodes;

  /// Dio exception types that should trigger a retry
  final List<DioExceptionType> retryableExceptionTypes;

  /// Calculate delay for nth retry using exponential backoff with jitter.
  ///
  /// Jitter prevents "thundering herd" problem where all clients retry
  /// at exactly the same time after a server recovers.
  Duration getDelay(int attempt) {
    // Exponential: 500ms, 1000ms, 2000ms, 4000ms...
    final exponentialDelayMs =
        initialDelay.inMilliseconds * pow(backoffMultiplier, attempt);

    // Add jitter: ±30% randomization
    final jitter = Random().nextDouble() * 0.3;
    final jitterMultiplier = 1 + (Random().nextBool() ? jitter : -jitter);
    final delayWithJitterMs = exponentialDelayMs * jitterMultiplier;

    // Cap at maxDelay
    final finalDelayMs = delayWithJitterMs.clamp(0, maxDelay.inMilliseconds);
    return Duration(milliseconds: finalDelayMs.toInt());
  }

  /// Determine if a failed request should be retried.
  ///
  /// By default, POST/PUT/DELETE are NOT retried (not idempotent).
  /// Set `options.extra['retryable'] = true` to override.
  bool shouldRetry(DioException error, int attempt) {
    // Exceeded max retries
    if (attempt >= maxRetries) return false;

    // Check if method is safe to retry (idempotent)
    final method = error.requestOptions.method.toUpperCase();
    final isMutationMethod = ['POST', 'PUT', 'DELETE', 'PATCH'].contains(method);

    if (isMutationMethod) {
      // Only retry mutations if explicitly marked as retryable
      final isExplicitlyRetryable = error.requestOptions.extra['retryable'] == true;
      if (!isExplicitlyRetryable) return false;
    }

    // Check if exception type is retryable
    if (retryableExceptionTypes.contains(error.type)) return true;

    // Check if status code is retryable
    final statusCode = error.response?.statusCode;
    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }

  /// Get retry-after duration from 429 response headers (if available)
  Duration? getRetryAfterFromHeaders(Response? response) {
    if (response == null) return null;

    final retryAfter = response.headers.value('retry-after');
    if (retryAfter == null) return null;

    // Try parsing as seconds (most common)
    final seconds = int.tryParse(retryAfter);
    if (seconds != null) return Duration(seconds: seconds);

    // Could also be HTTP-date format, but that's rare
    return null;
  }
}
