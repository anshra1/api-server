// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => _TaskModel(
  id: json['id'] as String,
  title: json['title'] as String? ?? 'No Title',
  subtitle: json['subtitle'] as String? ?? '',
  isCompleted: json['isCompleted'] as bool? ?? false,
  priority: json['priority'] as String? ?? 'medium',
  dueDate: json['dueDate'] as String?,
  category: json['category'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  userId: json['userId'] as String?,
);

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'isCompleted': instance.isCompleted,
      'priority': instance.priority,
      'dueDate': instance.dueDate,
      'category': instance.category,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'userId': instance.userId,
    };
