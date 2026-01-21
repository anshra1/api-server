import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
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

  TaskFilter _currentFilter = const TaskFilter();

  TaskCubit({
    required this.getTasks,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
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

    final result = await getTasks.call(filter: _currentFilter);

    result.fold(
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
        ));
      },
    );
  }

  /// Refresh tasks (reload from first page)
  Future<void> refresh() async {
    await loadTasks(refresh: true);
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
        emit((state as TaskLoaded).copyWith(tasks: serverUpdatedList));
      },
    );
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(Task task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
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
      },
    );
  }
}
