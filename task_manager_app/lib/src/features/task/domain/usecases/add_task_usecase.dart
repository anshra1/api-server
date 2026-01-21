import '../../../../core/common/typedef.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for adding a new task
class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  /// Execute with task details
  ResultFuture<Task> call({
    required String title,
    String? subtitle,
    String? priority,
    DateTime? dueDate,
    String? category,
  }) {
    return repository.createTask(
      title: title,
      subtitle: subtitle,
      priority: priority,
      dueDate: dueDate,
      category: category,
    );
  }
}
