import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task_stats.dart';

part 'task_stats_model.freezed.dart';
part 'task_stats_model.g.dart';

/// Task statistics model from API response
@freezed
abstract class TaskStatsModel with _$TaskStatsModel {
  const factory TaskStatsModel({
    @Default(0) int total,
    @Default(0) int completed,
    @Default(0) int pending,
    @Default(0) int highPriority,
    @Default(0) int overdue,
  }) = _TaskStatsModel;

  factory TaskStatsModel.fromJson(Map<String, dynamic> json) =>
      _$TaskStatsModelFromJson(json);
}

extension TaskStatsModelX on TaskStatsModel {
  /// Convert to domain entity
  TaskStats toEntity() {
    return TaskStats(
      total: total,
      completed: completed,
      pending: pending,
      highPriority: highPriority,
      overdue: overdue,
    );
  }
}
