import 'dart:io';
import 'package:dio/dio.dart';
import '../models/task_model.dart';

class ApiService {
  final Dio _dio = Dio();

  // Determine the Base URL based on the platform
  static String get baseUrl {
    return Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://127.0.0.1:3000';
  }

  static const String tasksEndpoint = '/tasks';

  // 1. GET All Tasks
  Future<List<Task>> getTasks() async {
    try {
      final url = '$baseUrl$tasksEndpoint';
      final response = await _dio.get(url);
      
      // Convert the List<dynamic> from Dio into a List<Task>
      final List<dynamic> data = response.data;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  // 2. CREATE a Task
  Future<Task> createTask(String title, String subtitle) async {
    try {
      final url = '$baseUrl$tasksEndpoint';
      final response = await _dio.post(
        url,
        data: {
          "title": title,
          "subtitle": subtitle,
        },
      );
      return Task.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // 3. UPDATE a Task (PUT)
  Future<void> updateTask(Task task) async {
    try {
      final url = '$baseUrl$tasksEndpoint/${task.id}';
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

  // 4. DELETE a Task
  Future<void> deleteTask(String id) async {
    try {
      final url = '$baseUrl$tasksEndpoint/$id';
      await _dio.delete(url);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
