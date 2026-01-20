import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/core/di/injection_container.dart';
import 'src/core/routing/app_router.dart';
import 'src/features/auth/presentation/cubit/auth_cubit.dart';
import 'src/features/task/presentation/cubit/task_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(
          create: (_) => sl<TaskCubit>()..loadTasks(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager (Clean Arch)',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}