import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import '../../../../core/common/paginated_response.dart';
import '../../../../core/common/typedef.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/paginated_tasks.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_stats.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';
import '../models/task_stats_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<PaginatedTasks> getTasks({TaskFilter? filter}) async {
    try {
      final f = filter ?? const TaskFilter();

      final result = await remoteDataSource.getTasks(
        page: f.page,
        limit: f.limit,
        sort: f.sort,
        order: f.order,
        search: f.search,
        isCompleted: f.isCompleted?.toString(),
        priority: f.priority?.name,
        category: f.category,
      );

      // Parse tasks from response
      final tasksJson = result['tasks'] as List<dynamic>? ?? [];
      final tasks = tasksJson
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();

      // Parse pagination from response
      final paginationJson = result['pagination'] as Map<String, dynamic>? ?? {};
      final pagination = PaginationInfo(
        page: paginationJson['page'] as int? ?? 1,
        limit: paginationJson['limit'] as int? ?? 20,
        total: paginationJson['total'] as int? ?? 0,
        totalPages: paginationJson['totalPages'] as int? ?? 0,
      );

      return Right(PaginatedTasks(tasks: tasks, pagination: pagination));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<TaskStats> getTaskStats() async {
    try {
      final result = await remoteDataSource.getTaskStats();
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<String>> getCategories() async {
    try {
      final result = await remoteDataSource.getCategories();
      final categories = (result['categories'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      return Right(categories);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Task> createTask({
    required String title,
    String? subtitle,
    String? priority,
    DateTime? dueDate,
    String? category,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (priority != null) 'priority': priority,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        if (category != null) 'category': category,
      };

      final result = await remoteDataSource.createTask(body);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Task> updateTask(Task task) async {
    try {
      final body = task.toJson();
      final result = await remoteDataSource.updateTask(task.id, body);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
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
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<int> batchComplete(List<String> ids, bool isCompleted) async {
    try {
      final result = await remoteDataSource.batchComplete({
        'ids': ids,
        'isCompleted': isCompleted,
      });
      return Right(result['updated'] as int? ?? 0);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<int> batchDelete(List<String> ids) async {
    try {
      final result = await remoteDataSource.batchDelete({'ids': ids});
      return Right(result['deleted'] as int? ?? 0);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
