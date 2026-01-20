import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';

class TaskListScreen extends StatelessWidget {
  final Talker talker;
  
  const TaskListScreen({super.key, required this.talker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager (Cubit)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
          IconButton(
            icon: const Icon(Icons.monitor_heart),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TalkerScreen(talker: talker),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TaskCubit>().loadTasks(),
          ),
        ],
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            talker.error('TaskCubit Error', state.message);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is TaskLoading || state is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            final tasks = state.tasks;
            if (tasks.isEmpty) {
              return const Center(child: Text('No tasks found. Add one!'));
            }
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    context.read<TaskCubit>().deleteTask(task.id);
                  },
                  child: ListTile(
                    leading: CircleAvatar(child: Text((index + 1).toString())),
                    title: Text(task.title),
                    subtitle: Text(task.subtitle),
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (val) {
                        if (val != null) {
                          final updatedTask = task.copyWith(isCompleted: val);
                          context.read<TaskCubit>().updateTask(updatedTask);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is TaskError) {
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
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<TaskCubit>().addTask(
            "Clean Arch Task ${DateTime.now().second}",
            "Separation of concerns!",
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
