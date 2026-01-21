import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/typedef.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_error_mapper.dart';
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
      final result = await _remoteDataSource.register({
        'email': email,
        'password': password,
        'name': name,
      });

      // Save tokens to secure storage
      await _localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> login(String email, String password) async {
    try {
      final result = await _remoteDataSource.login({
        'email': email,
        'password': password,
      });

      // Save tokens to secure storage
      await _localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
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
      await _remoteDataSource.changePassword({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      // Clear tokens after password change (user needs to re-login)
      await _localDataSource.clearTokens();
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
