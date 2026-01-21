import 'task.dart';

/// Filter parameters for fetching tasks
class TaskFilter {
  final int page;
  final int limit;
  final String? sort;
  final String? order;
  final String? search;
  final bool? isCompleted;
  final TaskPriority? priority;
  final String? category;

  const TaskFilter({
    this.page = 1,
    this.limit = 20,
    this.sort,
    this.order,
    this.search,
    this.isCompleted,
    this.priority,
    this.category,
  });

  /// Create a copy with updated values
  TaskFilter copyWith({
    int? page,
    int? limit,
    String? sort,
    String? order,
    String? search,
    bool? isCompleted,
    TaskPriority? priority,
    String? category,
    bool clearSearch = false,
    bool clearPriority = false,
    bool clearCompleted = false,
    bool clearCategory = false,
  }) {
    return TaskFilter(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      search: clearSearch ? null : (search ?? this.search),
      isCompleted: clearCompleted ? null : (isCompleted ?? this.isCompleted),
      priority: clearPriority ? null : (priority ?? this.priority),
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  /// Move to next page
  TaskFilter nextPage() => copyWith(page: page + 1);

  /// Reset to first page (used when filters change)
  TaskFilter resetPage() => copyWith(page: 1);

  /// Clear all filters
  TaskFilter clear() => const TaskFilter();

  /// Check if any filter is active
  bool get hasActiveFilters =>
      search != null || isCompleted != null || priority != null || category != null;

  /// Convert to query parameters for API call
  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (sort != null) params['sort'] = sort!;
    if (order != null) params['order'] = order!;
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (isCompleted != null) params['isCompleted'] = isCompleted.toString();
    if (priority != null) params['priority'] = priority!.name;
    if (category != null) params['category'] = category!;

    return params;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskFilter &&
        other.page == page &&
        other.limit == limit &&
        other.sort == sort &&
        other.order == order &&
        other.search == search &&
        other.isCompleted == isCompleted &&
        other.priority == priority &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(
        page,
        limit,
        sort,
        order,
        search,
        isCompleted,
        priority,
        category,
      );
}
