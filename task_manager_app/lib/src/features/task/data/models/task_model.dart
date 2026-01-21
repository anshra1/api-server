import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Task model from API response
@freezed
sealed class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    @Default('No Title') String title,
    @Default('') String subtitle,
    @Default(false) bool isCompleted,
    @Default('medium') String priority, // 'low', 'medium', 'high'
    String? dueDate, // ISO 8601 date string
    String? category,
    String? createdAt,
    String? updatedAt,
    String? userId,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
}

extension TaskModelX on TaskModel {
  /// Convert TaskModel to domain Task entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      subtitle: subtitle,
      isCompleted: isCompleted,
      priority: _parsePriority(priority),
      dueDate: dueDate != null ? DateTime.tryParse(dueDate!) : null,
      category: category,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }

  TaskPriority _parsePriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}

extension TaskToModel on Task {
  /// Convert domain Task entity to TaskModel for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isCompleted': isCompleted,
      'priority': priority.name,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      if (category != null) 'category': category,
    };
  }
}
