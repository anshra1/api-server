import '../../../../core/common/typedef.dart';
import '../entities/task_stats.dart';
import '../repositories/task_repository.dart';

/// Use case for getting task statistics
class GetTaskStatsUseCase {
  final TaskRepository repository;

  GetTaskStatsUseCase(this.repository);

  /// Execute
  ResultFuture<TaskStats> call() {
    return repository.getTaskStats();
  }
}
