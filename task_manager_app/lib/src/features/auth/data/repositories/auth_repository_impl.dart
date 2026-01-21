import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/typedef.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  ResultFuture<void> register(String email, String password, String name) async {
    try {
      final result = await _remoteDataSource.register(email, password, name);

      // Save tokens to secure storage
      await _localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> login(String email, String password) async {
    try {
      final result = await _remoteDataSource.login(email, password);

      // Save tokens to secure storage
      await _localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<bool> checkAuthStatus() async {
    try {
      final token = await _localDataSource.getAccessToken();
      // In a real app, we might also verify the token's validity with the server
      // or check expiration locally (if decoding JWT).
      // For now, presence of token = logged in.
      return Right(token != null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> logout() async {
    try {
      await _localDataSource.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _remoteDataSource.changePassword(currentPassword, newPassword);
      // Clear tokens after password change (user needs to re-login)
      await _localDataSource.clearTokens();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Handle Dio errors and extract server error messages
  Failure _handleDioError(DioException e) {
    String message = 'Unknown Server Error';

    // Try to extract error message from server response
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        // Handle standardized error format: { error: { message: "..." } }
        if (data['error'] is Map<String, dynamic>) {
          message = data['error']['message'] ?? message;
        } else if (data['error'] is String) {
          message = data['error'];
        } else if (data['message'] is String) {
          message = data['message'];
        }
      }
    } else {
      message = e.message ?? message;
    }

    return ServerFailure(
      message: message,
      code: e.response?.statusCode?.toString(),
    );
  }
}
