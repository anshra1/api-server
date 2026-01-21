import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'src/core/di/injection_container.dart';
import 'src/core/routing/app_router.dart';
import 'src/features/auth/presentation/cubit/auth_cubit.dart';
import 'src/features/task/presentation/cubit/task_cubit.dart';
import 'src/features/user/presentation/cubit/user_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()..checkAuthStatus()),
        // Load tasks AND stats on init
        BlocProvider(
            create: (_) => sl<TaskCubit>()
              ..loadTasks()
              ..loadStats()),
        // Provide UserCubit globally (lazy load is fine, but provider needed)
        BlocProvider(create: (_) => sl<UserCubit>()),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              // Global Auth State Listener
              // When user is logged out (from any source), navigate to login
              if (state is AuthUnauthenticated) {
                context.go('/login');
              }
              // When user is authenticated, navigate to tasks
              if (state is AuthAuthenticated) {
                context.go('/tasks');
                // Also reload tasks/stats when re-authenticating
                context.read<TaskCubit>().refresh();
              }
            },
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Task Manager (Clean Arch)',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                // inputDecorationTheme: const InputDecorationTheme(
                //   border: OutlineInputBorder(),
                //   filled: true,
                // ),
              ),
              routerConfig: AppRouter.router,
            ),
          );
        },
      ),
    );
  }
}
