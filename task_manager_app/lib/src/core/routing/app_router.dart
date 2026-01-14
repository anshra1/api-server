import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../features/task/presentation/pages/task_list_screen.dart';
import '../di/injection_container.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    observers: [TalkerRouteObserver(sl<Talker>())],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => TaskListScreen(talker: sl<Talker>()),
      ),
    ],
  );
}
