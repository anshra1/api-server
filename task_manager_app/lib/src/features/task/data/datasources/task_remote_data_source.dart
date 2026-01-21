import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/task_model.dart';
import '../models/task_stats_model.dart';

part 'task_remote_data_source.g.dart';

/// Retrofit client for task API
@RestApi()
abstract class TaskRemoteDataSource {
  factory TaskRemoteDataSource(Dio dio, {String baseUrl}) = _TaskRemoteDataSource;

  /// Get tasks with optional pagination, search, and filters
  @GET('/tasks')
  Future<Map<String, dynamic>> getTasks({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('sort') String? sort,
    @Query('order') String? order,
    @Query('search') String? search,
    @Query('isCompleted') String? isCompleted,
    @Query('priority') String? priority,
    @Query('category') String? category,
  });

  /// Get task statistics
  @GET('/tasks/stats')
  Future<TaskStatsModel> getTaskStats();

  /// Get all unique categories
  @GET('/tasks/categories')
  Future<Map<String, dynamic>> getCategories();

  /// Get a single task by ID
  @GET('/tasks/{id}')
  Future<TaskModel> getTaskById(@Path('id') String id);

  /// Create a new task
  @POST('/tasks')
  Future<TaskModel> createTask(@Body() Map<String, dynamic> body);

  /// Update an existing task
  @PUT('/tasks/{id}')
  Future<TaskModel> updateTask(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Delete a task
  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path('id') String id);

  /// Batch complete/uncomplete tasks
  @POST('/tasks/batch/complete')
  Future<Map<String, dynamic>> batchComplete(@Body() Map<String, dynamic> body);

  /// Batch delete tasks
  @DELETE('/tasks/batch')
  Future<Map<String, dynamic>> batchDelete(@Body() Map<String, dynamic> body);
}
