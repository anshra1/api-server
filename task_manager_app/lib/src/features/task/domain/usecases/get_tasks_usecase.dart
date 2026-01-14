import '../../../../core/common/typedef.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  ResultFuture<List<Task>> call() {
    return repository.getTasks();
  }
}