import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
sealed class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    @Default('No Title') String title,
    @Default('') String subtitle,
    @Default(false) bool isCompleted,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
}

extension TaskModelX on TaskModel {
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      subtitle: subtitle,
      isCompleted: isCompleted,
    );
  }
}
