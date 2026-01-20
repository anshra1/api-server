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
  ResultFuture<void> login(String username, String password) async {
    try {
      final result = await _remoteDataSource.login(username, password);
      
      // Save tokens to secure storage
      await _localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.statusMessage ?? e.message ?? 'Unknown Server Error',
          code: e.response?.statusCode?.toString(),
        ),
      );
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
}
