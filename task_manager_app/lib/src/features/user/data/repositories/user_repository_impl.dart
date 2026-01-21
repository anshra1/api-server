import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/typedef.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/data/models/user_model.dart'; // Import extension
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<User> getProfile() async {
    try {
      final result = await remoteDataSource.getProfile();
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<User> updateProfile({String? name, String? picture}) async {
    try {
      final result = await remoteDataSource.updateProfile(name: name, picture: picture);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteAccount(String password) async {
    try {
      await remoteDataSource.deleteAccount(password);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Map<String, dynamic>> getAccountStats() async {
    try {
      final result = await remoteDataSource.getAccountStats();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    String message = 'Unknown Server Error';
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
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
