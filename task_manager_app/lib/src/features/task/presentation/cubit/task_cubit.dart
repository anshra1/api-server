import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase getTasks;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskCubit({
    required this.getTasks,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(TaskInitial());

  // 1. Load Tasks
  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await getTasks.call();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // 2. Add Task
  Future<void> addTask(String title, String subtitle) async {
    try {
      final currentState = state;
      // Optimistic logic... (Optional, kept simple for now)
      
      await addTaskUseCase.call(title, subtitle);
      await loadTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // 3. Update Task
  Future<void> updateTask(Task task) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.tasks.map((t) {
        return t.id == task.id ? task : t;
      }).toList();
      emit(TaskLoaded(updatedTasks));

      try {
        await updateTaskUseCase.call(task);
      } catch (e) {
        emit(TaskError("Failed to update: ${e.toString()}"));
        loadTasks();
      }
    }
  }

  // 4. Delete Task
  Future<void> deleteTask(String id) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.tasks.where((t) => t.id != id).toList();
      emit(TaskLoaded(updatedTasks));

      try {
        await deleteTaskUseCase.call(id);
      } catch (e) {
        emit(TaskError("Failed to delete: ${e.toString()}"));
        loadTasks();
      }
    }
  }
}
