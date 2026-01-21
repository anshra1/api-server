import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/typedef.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../auth/data/models/user_model.dart';
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
      return Left(DioErrorMapper.toFailure(e));
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
      return Left(DioErrorMapper.toFailure(e));
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
      return Left(DioErrorMapper.toFailure(e));
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
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
