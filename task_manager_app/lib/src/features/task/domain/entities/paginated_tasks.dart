import '../../../../core/common/paginated_response.dart';
import 'task.dart';

/// Paginated tasks result
class PaginatedTasks {
  final List<Task> tasks;
  final PaginationInfo pagination;

  const PaginatedTasks({
    required this.tasks,
    required this.pagination,
  });

  /// Check if there are more pages
  bool get hasMore => pagination.page < pagination.totalPages;

  /// Check if this is the first page
  bool get isFirstPage => pagination.page == 1;

  /// Check if list is empty
  bool get isEmpty => tasks.isEmpty;

  /// Create empty result
  const PaginatedTasks.empty()
      : tasks = const [],
        pagination = const PaginationInfo();
}
