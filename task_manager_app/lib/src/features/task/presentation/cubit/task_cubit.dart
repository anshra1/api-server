import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
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
    final result = await getTasks.call();

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TaskLoaded(tasks)),
    );
  }

  // 2. Add Task
  Future<void> addTask(String title, String subtitle) async {
    // Note: We could use optimistic update here, but for simplicity we await.
    // Ideally emit loading?

    final result = await addTaskUseCase.call(title, subtitle);

    result.fold((failure) => emit(TaskError(failure.message)), (newTask) {
      // Reload list to be safe, or append locally
      loadTasks();
    });
  }

  // 3. Update Task
  Future<void> updateTask(Task task) async {
    // Optimistic Update
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedList = currentState.tasks
          .map((t) => t.id == task.id ? task : t)
          .toList();
      emit(TaskLoaded(updatedList));

      final result = await updateTaskUseCase.call(task);

      result.fold(
        (failure) {
          emit(TaskError("Update Failed: ${failure.message}"));
          loadTasks(); // Revert
        },
        (success) {
          // Success, do nothing as we already updated optimistically
        },
      );
    }
  }

  // 4. Delete Task
  Future<void> deleteTask(String id) async {
    // Optimistic Delete
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedList = currentState.tasks.where((t) => t.id != id).toList();
      emit(TaskLoaded(updatedList));

      final result = await deleteTaskUseCase.call(id);

      result.fold(
        (failure) {
          emit(TaskError("Delete Failed: ${failure.message}"));
          loadTasks(); // Revert
        },
        (success) {
          // Success
        },
      );
    }
  }
}
