import 'package:equatable/equatable.dart';

import '../../../../core/common/paginated_response.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_stats.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class TaskInitial extends TaskState {}

/// Loading state (for initial load)
final class TaskLoading extends TaskState {}

/// Loading more state (for pagination)
final class TaskLoadingMore extends TaskState {
  final List<Task> tasks;
  final PaginationInfo pagination;
  final TaskFilter filter;

  const TaskLoadingMore({
    required this.tasks,
    required this.pagination,
    required this.filter,
  });

  @override
  List<Object?> get props => [tasks, pagination, filter];
}

/// Tasks loaded successfully
final class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final PaginationInfo pagination;
  final TaskFilter filter;
  final bool hasMore;
  final TaskStats? stats;

  const TaskLoaded({
    required this.tasks,
    required this.pagination,
    required this.filter,
    required this.hasMore,
    this.stats,
  });

  /// Check if any filter is active
  bool get hasActiveFilters => filter.hasActiveFilters;

  /// Check if list is empty
  bool get isEmpty => tasks.isEmpty;

  /// Copy with new values
  TaskLoaded copyWith({
    List<Task>? tasks,
    PaginationInfo? pagination,
    TaskFilter? filter,
    bool? hasMore,
    TaskStats? stats,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      pagination: pagination ?? this.pagination,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [tasks, pagination, filter, hasMore, stats];
}

/// Error state
final class TaskError extends TaskState {
  final String message;
  final TaskFilter? previousFilter;
  final List<Task>? previousTasks;

  const TaskError(
    this.message, {
    this.previousFilter,
    this.previousTasks,
  });

  @override
  List<Object?> get props => [message, previousFilter, previousTasks];
}
