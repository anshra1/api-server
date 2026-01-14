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

  // Factory constructor to create a Task from JSON (Server -> App)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'No Title',
      subtitle: json['subtitle'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  // Method to convert a Task to JSON (App -> Server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isCompleted': isCompleted,
    };
  }

  // Helper to create a copy of the task with some fields updated
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
