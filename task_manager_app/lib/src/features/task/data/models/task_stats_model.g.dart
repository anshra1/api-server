// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskStatsModel _$TaskStatsModelFromJson(Map<String, dynamic> json) =>
    _TaskStatsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      highPriority: (json['highPriority'] as num?)?.toInt() ?? 0,
      overdue: (json['overdue'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TaskStatsModelToJson(_TaskStatsModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'completed': instance.completed,
      'pending': instance.pending,
      'highPriority': instance.highPriority,
      'overdue': instance.overdue,
    };
