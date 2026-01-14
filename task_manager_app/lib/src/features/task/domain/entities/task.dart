class Task {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

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