import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Task>> getTasks() async {
    return await remoteDataSource.getTasks();
  }

  @override
  Future<Task> createTask(String title, String subtitle) async {
    return await remoteDataSource.createTask({
      'title': title,
      'subtitle': subtitle,
    });
  }

  @override
  Future<Task> updateTask(Task task) async {
    return await remoteDataSource.updateTask(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    return await remoteDataSource.deleteTask(id);
  }
}
