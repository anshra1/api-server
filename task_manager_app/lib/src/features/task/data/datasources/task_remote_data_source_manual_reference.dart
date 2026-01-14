import 'package:dio/dio.dart';

import '../models/task_model.dart';

/// ⚠️ REFERENCE ONLY ⚠️
/// This file shows how we used to write API calls MANUALLY before switching to Retrofit.
/// Use this to understand what 'api_service.g.dart' is doing behind the scenes.
class ApiServiceManualReference {
  final Dio _dio;

  // Manual dependency injection
  ApiServiceManualReference(this._dio);

  // Hardcoded endpoint
  static const String tasksEndpoint = '/tasks';

  // 1. GET All Tasks (Manual Way)
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await _dio.get(tasksEndpoint);

      // MANUAL PARSING: We had to type this out ourselves.
      // If we made a typo here, the app would crash.
      final List<dynamic> data = response.data;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  // 2. CREATE a Task (Manual Way)
  Future<TaskModel> createTask(String title, String subtitle) async {
    try {
      // MANUAL BODY CONSTRUCTION: We had to build the Map ourselves.
      final response = await _dio.post(
        tasksEndpoint,
        data: {"title": title, "subtitle": subtitle},
      );
      return TaskModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // 3. UPDATE a Task (Manual Way)
  Future<void> updateTask(TaskModel task) async {
    try {
      // MANUAL URL CONSTRUCTION: '$tasksEndpoint/${task.id}'
      final url = '$tasksEndpoint/${task.id}';
      await _dio.put(
        url,
        data: {
          'title': task.title,
          'subtitle': task.subtitle,
          'isCompleted': task.isCompleted,
        },
      );
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // 4. DELETE a Task (Manual Way)
  Future<void> deleteTask(String id) async {
    try {
      final url = '$tasksEndpoint/$id';
      await _dio.delete(url);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}