import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final ApiService _apiService;

  TaskCubit(this._apiService) : super(TaskInitial());

  // 1. Load Tasks
  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await _apiService.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // 2. Add Task
  Future<void> addTask(String title, String subtitle) async {
    try {
      // Optimistic update is tricky with Create because we need the ID from server.
      // So we show loading or keep current state?
      // For simplicity, we just reload after success, or append if we trust the return.
      
      final currentState = state;
      if (currentState is TaskLoaded) {
        // Optional: emit loading if you want a spinner
        // emit(TaskLoading()); 
      }

      await _apiService.createTask(title, subtitle);
      
      // Reload to get the fresh list (simplest approach)
      await loadTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // 3. Update Task
  Future<void> updateTask(Task task) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      // Optimistic Update
      final updatedTasks = currentState.tasks.map((t) {
        return t.id == task.id ? task : t;
      }).toList();
      
      emit(TaskLoaded(updatedTasks));

      try {
        await _apiService.updateTask(task);
      } catch (e) {
        // Revert on failure
        emit(TaskError("Failed to update: ${e.toString()}"));
        // Ideally, revert to the specific previous list, but reloading is safer
        loadTasks(); 
      }
    }
  }

  // 4. Delete Task
  Future<void> deleteTask(String id) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      // Optimistic Delete
      final updatedTasks = currentState.tasks.where((t) => t.id != id).toList();
      emit(TaskLoaded(updatedTasks));

      try {
        await _apiService.deleteTask(id);
      } catch (e) {
        emit(TaskError("Failed to delete: ${e.toString()}"));
        loadTasks();
      }
    }
  }
}
