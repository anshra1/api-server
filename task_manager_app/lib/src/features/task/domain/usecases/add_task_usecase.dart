import '../entities/task.dart';
import '../repositories/task_repository.dart';

class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  Future<Task> call(String title, String subtitle) {
    return repository.createTask(title, subtitle);
  }
}
