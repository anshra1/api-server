import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/task/presentation/pages/task_list_screen.dart';
import '../di/injection_container.dart';

/// AppRouter - Simplified for Mobile
///
/// Navigation logic is handled by the global BlocListener in app.dart.
/// This router only defines the routes, not the auth redirects.
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    observers: [TalkerRouteObserver(sl<Talker>())],
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => TaskListScreen(talker: sl<Talker>()),
      ),
    ],
  );
}
