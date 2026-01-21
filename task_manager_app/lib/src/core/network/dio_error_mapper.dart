import 'package:dio/dio.dart';

import '../error/failure.dart';
import '../error/network_exception.dart';

/// Utility to convert [DioException] with [NetworkException] to [Failure].
///
/// Use this in repositories to simplify error handling:
/// ```dart
/// } on DioException catch (e) {
///   return Left(DioErrorMapper.toFailure(e));
/// }
/// ```
class DioErrorMapper {
  DioErrorMapper._();

  /// Convert a caught error to a [Failure] for the domain layer.
  static Failure toFailure(Object error) {
    if (error is DioException && error.error is NetworkException) {
      return _mapNetworkException(error.error as NetworkException);
    }

    if (error is DioException) {
      // Fallback if ErrorMappingInterceptor wasn't applied
      return ServerFailure(
        message: error.message ?? 'Unknown network error',
        code: error.response?.statusCode?.toString(),
      );
    }

    return UnknownFailure(message: error.toString());
  }

  static Failure _mapNetworkException(NetworkException e) {
    // Determine if error is retryable (for UI to show retry button)
    final isRetryable =
        e is TimeoutException ||
        e is NoConnectionException ||
        e is ServerException ||
        e is RateLimitException;

    return NetworkFailure(
      message: e.message,
      code: e.errorCode,
      statusCode: e.statusCode,
      isRetryable: isRetryable,
    );
  }
}
