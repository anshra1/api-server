import '../../../../core/common/typedef.dart';
import '../entities/paginated_tasks.dart';
import '../entities/task_filter.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository _repository;

  GetTasksUseCase(this._repository);

  ResultFuture<PaginatedTasks> call({TaskFilter? filter}) async {
    return _repository.getTasks(filter: filter);
  }
}
