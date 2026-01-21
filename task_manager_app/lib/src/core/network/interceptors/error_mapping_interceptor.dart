import 'package:dio/dio.dart';

import '../../error/network_exception.dart';

/// Converts [DioException] to typed [NetworkException] for consistent error handling.
///
/// This interceptor standardizes all network errors into a sealed class hierarchy,
/// enabling exhaustive pattern matching in the repository/cubit layer.
class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final networkException = _mapToNetworkException(err);

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: networkException,
        type: err.type,
        response: err.response,
        stackTrace: err.stackTrace,
      ),
    );
  }

  NetworkException _mapToNetworkException(DioException err) {
    // Handle non-response errors (timeout, connection, cancel)
    if (err.type != DioExceptionType.badResponse) {
      return _mapDioExceptionType(err);
    }

    // Handle HTTP errors with status codes
    final statusCode = err.response?.statusCode;
    final message = _extractErrorMessage(err);
    final errorCode = _extractErrorCode(err);

    return switch (statusCode) {
      400 => BadRequestException(
        message: message,
        errorCode: errorCode,
        originalError: err,
      ),
      401 => UnauthorizedException(
        message: message,
        errorCode: errorCode,
        originalError: err,
      ),
      403 => ForbiddenException(
        message: message,
        errorCode: errorCode,
        originalError: err,
      ),
      404 => NotFoundException(
        message: message,
        errorCode: errorCode,
        originalError: err,
      ),
      409 => ConflictException(
        message: message,
        errorCode: errorCode,
        originalError: err,
      ),
      422 => ValidationException(
        message: message,
        errorCode: errorCode,
        originalError: err,
        fieldErrors: _extractFieldErrors(err),
      ),
      429 => RateLimitException(
        message: message,
        errorCode: errorCode,
        originalError: err,
        retryAfter: _extractRetryAfter(err),
      ),
      final int code when code >= 500 => ServerException(
        message: message,
        statusCode: code,
        errorCode: errorCode,
        originalError: err,
      ),
      _ => UnknownNetworkException(
        message: message,
        statusCode: statusCode,
        errorCode: errorCode,
        originalError: err,
      ),
    };
  }

  NetworkException _mapDioExceptionType(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => TimeoutException(
        message: 'Request timed out. Please try again.',
        originalError: err,
      ),
      DioExceptionType.connectionError => NoConnectionException(originalError: err),
      DioExceptionType.cancel => CancelledException(originalError: err),
      _ => UnknownNetworkException(
        message: err.message ?? 'An unexpected network error occurred.',
        originalError: err,
      ),
    };
  }

  /// Extract human-readable error message from response body.
  ///
  /// Supports common API error formats:
  /// - `{ "error": { "message": "..." } }`
  /// - `{ "error": "..." }`
  /// - `{ "message": "..." }`
  String _extractErrorMessage(DioException err) {
    final data = err.response?.data;

    if (data is Map<String, dynamic>) {
      // Nested error object
      if (data['error'] is Map<String, dynamic>) {
        return (data['error'] as Map<String, dynamic>)['message'] as String? ??
            'Unknown error';
      }
      // Direct error string
      if (data['error'] is String) {
        return data['error'] as String;
      }
      // Direct message
      if (data['message'] is String) {
        return data['message'] as String;
      }
    }

    return err.message ?? 'Unknown error';
  }

  /// Extract backend error code (e.g., "EMAIL_EXISTS", "TOKEN_EXPIRED")
  String? _extractErrorCode(DioException err) {
    final data = err.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['error'] is Map<String, dynamic>) {
        return (data['error'] as Map<String, dynamic>)['code'] as String?;
      }
      if (data['code'] is String) {
        return data['code'] as String?;
      }
    }

    return null;
  }

  /// Extract field-specific validation errors for 422 responses.
  ///
  /// Supports format: `{ "errors": { "email": "Invalid", "password": "Too short" } }`
  Map<String, String>? _extractFieldErrors(DioException err) {
    final data = err.response?.data;

    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map((key, value) => MapEntry(key, value.toString()));
      }
    }

    return null;
  }

  /// Extract Retry-After duration from 429 response headers.
  Duration? _extractRetryAfter(DioException err) {
    final retryAfter = err.response?.headers.value('retry-after');
    if (retryAfter == null) return null;

    final seconds = int.tryParse(retryAfter);
    if (seconds != null) return Duration(seconds: seconds);

    return null;
  }
}
