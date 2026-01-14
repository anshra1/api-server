import '../../../../core/common/typedef.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  ResultFuture<Task> call(Task task) {
    return repository.updateTask(task);
  }
}