/// Network-specific exceptions for HTTP error handling.
///
/// This is a sealed class hierarchy enabling exhaustive pattern matching
/// for all possible network error types.
sealed class NetworkException implements Exception {
  const NetworkException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.originalError,
  });

  /// Human-readable error message
  final String message;

  /// HTTP status code (if applicable)
  final int? statusCode;

  /// Backend error code (e.g., "EMAIL_EXISTS", "TOKEN_EXPIRED")
  final String? errorCode;

  /// Original error for debugging
  final Object? originalError;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

/// 400 Bad Request - Invalid request syntax or parameters
final class BadRequestException extends NetworkException {
  const BadRequestException({
    required super.message,
    super.errorCode,
    super.originalError,
  }) : super(statusCode: 400);
}

/// 401 Unauthorized - Authentication required or token invalid
final class UnauthorizedException extends NetworkException {
  const UnauthorizedException({
    required super.message,
    super.errorCode,
    super.originalError,
  }) : super(statusCode: 401);
}

/// 403 Forbidden - Access denied (authenticated but not authorized)
final class ForbiddenException extends NetworkException {
  const ForbiddenException({required super.message, super.errorCode, super.originalError})
    : super(statusCode: 403);
}

/// 404 Not Found - Resource doesn't exist
final class NotFoundException extends NetworkException {
  const NotFoundException({required super.message, super.errorCode, super.originalError})
    : super(statusCode: 404);
}

/// 409 Conflict - Request conflicts with current state
final class ConflictException extends NetworkException {
  const ConflictException({required super.message, super.errorCode, super.originalError})
    : super(statusCode: 409);
}

/// 422 Unprocessable Entity - Validation errors
final class ValidationException extends NetworkException {
  const ValidationException({
    required super.message,
    super.errorCode,
    super.originalError,
    this.fieldErrors,
  }) : super(statusCode: 422);

  /// Field-specific validation errors (e.g., {"email": "Invalid format"})
  final Map<String, String>? fieldErrors;
}

/// 429 Too Many Requests - Rate limited
final class RateLimitException extends NetworkException {
  const RateLimitException({
    required super.message,
    super.errorCode,
    super.originalError,
    this.retryAfter,
  }) : super(statusCode: 429);

  /// Seconds to wait before retrying (from Retry-After header)
  final Duration? retryAfter;
}

/// 5xx Server Error - Server-side failure
final class ServerException extends NetworkException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
  });
}

/// Request timed out
final class TimeoutException extends NetworkException {
  const TimeoutException({required super.message, super.originalError})
    : super(statusCode: null);
}

/// No internet connection
final class NoConnectionException extends NetworkException {
  const NoConnectionException({
    super.message = 'No internet connection. Please check your network.',
    super.originalError,
  }) : super(statusCode: null);
}

/// Request was cancelled
final class CancelledException extends NetworkException {
  const CancelledException({
    super.message = 'Request was cancelled.',
    super.originalError,
  }) : super(statusCode: null);
}

/// Unknown or unhandled network error
final class UnknownNetworkException extends NetworkException {
  const UnknownNetworkException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
  });
}
