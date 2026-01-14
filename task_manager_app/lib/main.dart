import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/task_cubit.dart';
import 'cubits/task_state.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager (Cubit)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
        ), // Purple for Bloc/Cubit
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => TaskCubit(ApiService())..loadTasks(),
        child: const TaskListScreen(),
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager (Cubit)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TaskCubit>().loadTasks(),
          ),
        ],
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
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
            // If we have an error but no data (e.g. initial load failed)
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
            "Cubit Task ${DateTime.now().second}",
            "State Management is awesome",
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
