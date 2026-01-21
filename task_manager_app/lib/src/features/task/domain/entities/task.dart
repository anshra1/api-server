/// Task priority levels
enum TaskPriority { low, medium, high }

/// Task domain entity
class Task {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? category;
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.category,
    this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
    String? category,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
