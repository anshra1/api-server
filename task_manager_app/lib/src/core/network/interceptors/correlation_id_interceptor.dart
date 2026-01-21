import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Adds a unique correlation ID to every request for tracing.
///
/// The correlation ID is added as `X-Request-ID` header and can be used to:
/// - Track requests across client and server logs
/// - Debug specific user issues in production
/// - Correlate errors in crash reporting tools
class CorrelationIdInterceptor extends Interceptor {
  /// HTTP header name for the correlation ID
  static const headerName = 'X-Request-ID';

  /// UUID generator
  static const _uuid = Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Generate unique request ID
    final requestId = _uuid.v4();

    // Add to headers (sent to server)
    options.headers[headerName] = requestId;

    // Store in extra for access in onResponse/onError
    options.extra['requestId'] = requestId;
    options.extra['requestStartTime'] = DateTime.now();

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logRequestCompletion(response.requestOptions, 'SUCCESS', response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logRequestCompletion(err.requestOptions, 'FAILED', err.response?.statusCode);
    handler.next(err);
  }

  void _logRequestCompletion(RequestOptions options, String status, int? statusCode) {
    final requestId = options.extra['requestId'] as String?;
    final startTime = options.extra['requestStartTime'] as DateTime?;

    if (startTime != null && requestId != null) {
      final duration = DateTime.now().difference(startTime);
      final statusCodeStr = statusCode != null ? ' ($statusCode)' : '';

      debugPrint(
        '[$requestId] ${options.method} ${options.path} '
        '$status$statusCodeStr [${duration.inMilliseconds}ms]',
      );
    }
  }
}
