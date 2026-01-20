import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/task/presentation/pages/task_list_screen.dart';
import '../di/injection_container.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
   // refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
    observers: [TalkerRouteObserver(sl<Talker>())],
    redirect: (context, state) {
      final authState = sl<AuthCubit>().state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/tasks';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => TaskListScreen(talker: sl<Talker>()),
      ),
    ],
  );
}