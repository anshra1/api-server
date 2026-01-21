import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_task_stats_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase getTasks;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final GetTaskStatsUseCase getTaskStatsUseCase;

  TaskFilter _currentFilter = const TaskFilter();

  TaskCubit({
    required this.getTasks,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTaskStatsUseCase,
  }) : super(TaskInitial());

  /// Current filter
  TaskFilter get currentFilter => _currentFilter;

  /// Load tasks with optional filter
  Future<void> loadTasks({TaskFilter? filter, bool refresh = false}) async {
    if (filter != null) {
      _currentFilter = filter;
    }
    if (refresh) {
      _currentFilter = _currentFilter.copyWith(page: 1);
    }

    emit(TaskLoading());

    // Fetch tasks
    final taskResult = await getTasks.call(filter: _currentFilter);
    // Fetch stats concurrently if not loading more (i.e. first page or refresh)
    // We only need global stats, not filtered stats for the dashboard at top
    // Ideally stats should be its own call, but we can bundle it here for simplicity
    // Or we can let the UI trigger it separately

    // For now, let's just emit tasks. We will add a separate method for stats.

    taskResult.fold(
      (failure) => emit(TaskError(failure.message)),
      (paginatedTasks) {
        emit(TaskLoaded(
          tasks: paginatedTasks.tasks,
          pagination: paginatedTasks.pagination,
          filter: _currentFilter,
          hasMore: paginatedTasks.hasMore,
        ));
      },
    );
  }

  /// Load global task statistics
  Future<void> loadStats() async {
    final currentState = state;
    // We can only attach stats if we are in loaded state (or we can emit a separate state if needed)
    // But since stats are usually shown with the list, let's attach to TaskLoaded

    if (currentState is TaskLoaded) {
      final result = await getTaskStatsUseCase.call();
      result.fold(
        (failure) {
          // Silently fail or log? Stats failure shouldn't block the list.
          // Maybe show a snackbar via listener but we don't have a specific state for "StatsError"
        },
        (stats) {
          emit(currentState.copyWith(stats: stats));
        },
      );
    }
  }

  /// Load more tasks (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! TaskLoaded || !currentState.hasMore) return;

    // Emit loading more state
    emit(TaskLoadingMore(
      tasks: currentState.tasks,
      pagination: currentState.pagination,
      filter: currentState.filter,
    ));

    _currentFilter = _currentFilter.nextPage();
    final result = await getTasks.call(filter: _currentFilter);

    result.fold(
      (failure) {
        // Revert filter on error
        _currentFilter = _currentFilter.copyWith(page: _currentFilter.page - 1);
        emit(TaskError(
          failure.message,
          previousFilter: currentState.filter,
          previousTasks: currentState.tasks,
        ));
      },
      (paginatedTasks) {
        emit(TaskLoaded(
          tasks: [...currentState.tasks, ...paginatedTasks.tasks],
          pagination: paginatedTasks.pagination,
          filter: _currentFilter,
          hasMore: paginatedTasks.hasMore,
          stats: currentState.stats, // Preserve stats
        ));
      },
    );
  }

  /// Refresh tasks (reload from first page)
  Future<void> refresh() async {
    // When refreshing, we should probably re-fetch stats too if we want them fresh
    await loadTasks(refresh: true);
    await loadStats();
  }

  /// Search tasks
  void search(String query) {
    final newFilter = _currentFilter.copyWith(
      search: query.isEmpty ? null : query,
      page: 1,
      clearSearch: query.isEmpty,
    );
    loadTasks(filter: newFilter);
  }

  /// Filter by priority
  void filterByPriority(TaskPriority? priority) {
    final newFilter = _currentFilter.copyWith(
      priority: priority,
      page: 1,
      clearPriority: priority == null,
    );
    loadTasks(filter: newFilter);
  }

  /// Filter by completion status
  void filterByCompleted(bool? isCompleted) {
    final newFilter = _currentFilter.copyWith(
      isCompleted: isCompleted,
      page: 1,
      clearCompleted: isCompleted == null,
    );
    loadTasks(filter: newFilter);
  }

  /// Filter by category
  void filterByCategory(String? category) {
    final newFilter = _currentFilter.copyWith(
      category: category,
      page: 1,
      clearCategory: category == null,
    );
    loadTasks(filter: newFilter);
  }

  /// Clear all filters
  void clearFilters() {
    loadTasks(filter: const TaskFilter());
  }

  /// Add a new task
  Future<void> addTask({
    required String title,
    String? subtitle,
    String? priority,
    DateTime? dueDate,
    String? category,
  }) async {
    final result = await addTaskUseCase.call(
      title: title,
      subtitle: subtitle,
      priority: priority,
      dueDate: dueDate,
      category: category,
    );

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (newTask) {
        // Refresh the list to include new task
        refresh();
      },
    );
  }

  /// Update a task
  Future<void> updateTask(Task task) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    // Optimistic update
    final updatedList =
        currentState.tasks.map((t) => t.id == task.id ? task : t).toList();
    emit(currentState.copyWith(tasks: updatedList));

    final result = await updateTaskUseCase.call(task);

    result.fold(
      (failure) {
        emit(TaskError(
          "Update Failed: ${failure.message}",
          previousFilter: currentState.filter,
          previousTasks: currentState.tasks,
        ));
        // Revert by reloading
        loadTasks();
      },
      (updatedTask) {
        // Update with server response
        final serverUpdatedList = (state as TaskLoaded)
            .tasks
            .map((t) => t.id == updatedTask.id ? updatedTask : t)
            .toList();

        // If task completion changed, refreshing stats might be good,
        // but let's avoid too many requests for now or do it silently.
        // For accurate stats, we should re-fetch.
        if (task.isCompleted != updatedTask.isCompleted) {
          loadStats();
        }

        emit((state as TaskLoaded).copyWith(tasks: serverUpdatedList));
      },
    );
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(Task task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
    // Load stats after toggle to update "Completed" count
    loadStats();
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    // Optimistic delete
    final updatedList = currentState.tasks.where((t) => t.id != id).toList();
    emit(currentState.copyWith(tasks: updatedList));

    final result = await deleteTaskUseCase.call(id);

    result.fold(
      (failure) {
        emit(TaskError(
          "Delete Failed: ${failure.message}",
          previousFilter: currentState.filter,
          previousTasks: currentState.tasks,
        ));
        // Revert by reloading
        loadTasks();
      },
      (_) {
        // Success, task already removed optimistically
        loadStats(); // Update stats
      },
    );
  }
}
