import '../../../../core/common/typedef.dart';
import '../../domain/entities/task.dart';

abstract class TaskRepository {
  ResultFuture<List<Task>> getTasks();
  ResultFuture<Task> createTask(String title, String subtitle);
  ResultFuture<Task> updateTask(Task task);
  ResultFuture<void> deleteTask(String id);
}