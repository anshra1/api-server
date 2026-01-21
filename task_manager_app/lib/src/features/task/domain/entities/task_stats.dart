/// Task statistics entity
class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final int highPriority;
  final int overdue;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.highPriority,
    required this.overdue,
  });

  /// Calculate completion rate (0.0 to 1.0)
  double get completionRate => total > 0 ? completed / total : 0;

  /// Calculate completion percentage (0 to 100)
  int get completionPercentage => (completionRate * 100).round();

  /// Create empty stats
  const TaskStats.empty()
      : total = 0,
        completed = 0,
        pending = 0,
        highPriority = 0,
        overdue = 0;
}
