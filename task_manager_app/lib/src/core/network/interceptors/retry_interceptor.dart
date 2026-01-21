import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../retry_policy.dart';

/// Automatically retries failed requests based on [RetryPolicy].
///
/// Features:
/// - Exponential backoff with jitter
/// - Respects Retry-After headers for 429 responses
/// - Idempotency-aware: GET is retried, POST/PUT/DELETE are not (by default)
/// - Configurable via [RetryPolicy]
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, this.retryPolicy = const RetryPolicy()});

  /// Dio instance used to retry requests
  final Dio dio;

  /// Policy controlling retry behavior
  final RetryPolicy retryPolicy;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = err.requestOptions.extra['retryAttempt'] as int? ?? 0;

    if (retryPolicy.shouldRetry(err, attempt)) {
      // Check for Retry-After header (429 responses)
      final retryAfter = retryPolicy.getRetryAfterFromHeaders(err.response);
      final delay = retryAfter ?? retryPolicy.getDelay(attempt);

      final requestId = err.requestOptions.extra['requestId'] ?? 'unknown';
      debugPrint(
        '[$requestId] Retry ${attempt + 1}/${retryPolicy.maxRetries} '
        'after ${delay.inMilliseconds}ms',
      );

      await Future<void>.delayed(delay);

      try {
        // Clone request with incremented attempt counter
        final options = err.requestOptions;
        options.extra['retryAttempt'] = attempt + 1;

        final response = await dio.fetch<dynamic>(options);
        return handler.resolve(response);
      } on DioException catch (retryError) {
        // Retry failed, recurse to try again or propagate
        return onError(retryError, handler);
      }
    }

    // No more retries, propagate error to next interceptor
    handler.next(err);
  }
}
