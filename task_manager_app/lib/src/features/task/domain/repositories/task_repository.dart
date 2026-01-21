import '../../../../core/common/typedef.dart';
import '../entities/paginated_tasks.dart';
import '../entities/task.dart';
import '../entities/task_filter.dart';
import '../entities/task_stats.dart';

/// Abstract interface for task repository
abstract class TaskRepository {
  /// Get tasks with optional filter, pagination, and search
  ResultFuture<PaginatedTasks> getTasks({TaskFilter? filter});

  /// Get task statistics
  ResultFuture<TaskStats> getTaskStats();

  /// Get all unique categories
  ResultFuture<List<String>> getCategories();

  /// Create a new task
  ResultFuture<Task> createTask({
    required String title,
    String? subtitle,
    String? priority,
    DateTime? dueDate,
    String? category,
  });

  /// Update an existing task
  ResultFuture<Task> updateTask(Task task);

  /// Delete a task (soft delete)
  ResultFuture<void> deleteTask(String id);

  /// Batch complete/uncomplete tasks
  ResultFuture<int> batchComplete(List<String> ids, bool isCompleted);

  /// Batch delete tasks
  ResultFuture<int> batchDelete(List<String> ids);
}
