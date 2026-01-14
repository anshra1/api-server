import '../../../../core/common/typedef.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  ResultFuture<void> call(String id) {
    return repository.deleteTask(id);
  }
}