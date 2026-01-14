import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final String id;
  @JsonKey(defaultValue: 'No Title')
  final String title;
  @JsonKey(defaultValue: '')
  final String subtitle;
  @JsonKey(defaultValue: false)
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
