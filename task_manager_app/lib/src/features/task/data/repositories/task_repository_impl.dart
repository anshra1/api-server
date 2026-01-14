import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import '../../../../core/common/typedef.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<List<Task>> getTasks() async {
    try {
      final result = await remoteDataSource.getTasks();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.statusMessage ?? e.message ?? 'Unknown Server Error',
        code: e.response?.statusCode?.toString(),
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Task> createTask(String title, String subtitle) async {
    try {
      final result = await remoteDataSource.createTask({
        'title': title,
        'subtitle': subtitle,
      });
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.statusMessage ?? e.message ?? 'Unknown Server Error',
        code: e.response?.statusCode?.toString(),
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Task> updateTask(Task task) async {
    try {
      final result = await remoteDataSource.updateTask(task.id, task);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.statusMessage ?? e.message ?? 'Unknown Server Error',
        code: e.response?.statusCode?.toString(),
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.statusMessage ?? e.message ?? 'Unknown Server Error',
        code: e.response?.statusCode?.toString(),
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}