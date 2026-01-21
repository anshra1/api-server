import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';

class TaskListScreen extends StatefulWidget {
  final Talker talker;

  const TaskListScreen({super.key, required this.talker});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TaskCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
          IconButton(
            icon: const Icon(Icons.monitor_heart),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TalkerScreen(talker: widget.talker),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TaskCubit>().search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {}); // Update suffixIcon visibility
                context.read<TaskCubit>().search(value);
              },
            ),
          ),
          // Filter chips
          _buildFilterChips(context),
          // Task list
          Expanded(
            child: BlocConsumer<TaskCubit, TaskState>(
              listener: (context, state) {
                if (state is TaskError) {
                  widget.talker.error('TaskCubit Error', state.message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TaskLoading || state is TaskInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoaded || state is TaskLoadingMore) {
                  final tasks = state is TaskLoaded
                      ? state.tasks
                      : (state as TaskLoadingMore).tasks;
                  final isLoadingMore = state is TaskLoadingMore;

                  if (tasks.isEmpty) {
                    return _buildEmptyState(context, state);
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<TaskCubit>().refresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: tasks.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == tasks.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _buildTaskItem(context, tasks[index], index);
                      },
                    ),
                  );
                } else if (state is TaskError) {
                  return _buildErrorState(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildPriorityChip(context, 'High', TaskPriority.high, Colors.red),
          const SizedBox(width: 8),
          _buildPriorityChip(context, 'Medium', TaskPriority.medium, Colors.orange),
          const SizedBox(width: 8),
          _buildPriorityChip(context, 'Low', TaskPriority.low, Colors.green),
          const SizedBox(width: 16),
          _buildCompletedChip(context, 'Pending', false),
          const SizedBox(width: 8),
          _buildCompletedChip(context, 'Completed', true),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(
      BuildContext context, String label, TaskPriority priority, Color color) {
    final cubit = context.read<TaskCubit>();
    final isSelected = cubit.currentFilter.priority == priority;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        cubit.filterByPriority(selected ? priority : null);
      },
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
    );
  }

  Widget _buildCompletedChip(BuildContext context, String label, bool completed) {
    final cubit = context.read<TaskCubit>();
    final isSelected = cubit.currentFilter.isCompleted == completed;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        cubit.filterByCompleted(selected ? completed : null);
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, int index) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => context.read<TaskCubit>().deleteTask(task.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: _buildPriorityIndicator(task.priority),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.subtitle.isNotEmpty) Text(task.subtitle),
              if (task.dueDate != null || task.category != null)
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: task.isOverdue ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: task.isOverdue ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                    if (task.category != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.label, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        task.category!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
            ],
          ),
          trailing: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => context.read<TaskCubit>().toggleTaskCompletion(task),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.low:
        color = Colors.green;
        break;
    }

    return Container(
      width: 8,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TaskState state) {
    final hasFilters = state is TaskLoaded ? state.hasActiveFilters : false;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list_off : Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No tasks match your filters' : 'No tasks yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (hasFilters)
            TextButton(
              onPressed: () {
                _searchController.clear();
                context.read<TaskCubit>().clearFilters();
              },
              child: const Text('Clear filters'),
            )
          else
            Text(
              'Tap + to add your first task',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TaskError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(state.message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TaskCubit>().loadTasks(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    DateTime? dueDate;
    // ignore: unused_local_variable
    String? category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Task',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Priority: '),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Low'),
                    selected: priority == TaskPriority.low,
                    onSelected: (_) => setDialogState(() => priority = TaskPriority.low),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Medium'),
                    selected: priority == TaskPriority.medium,
                    onSelected: (_) =>
                        setDialogState(() => priority = TaskPriority.medium),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('High'),
                    selected: priority == TaskPriority.high,
                    onSelected: (_) => setDialogState(() => priority = TaskPriority.high),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => dueDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(dueDate != null
                    ? 'Due: ${_formatDate(dueDate!)}'
                    : 'Set due date (optional)'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    context.read<TaskCubit>().addTask(
                          title: titleController.text.trim(),
                          subtitle: subtitleController.text.trim().isNotEmpty
                              ? subtitleController.text.trim()
                              : null,
                          priority: priority.name,
                          dueDate: dueDate,
                          category: category,
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Task'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
