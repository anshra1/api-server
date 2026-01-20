import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:task_manager_app/src/core/network/auth_event_bus.dart';
import 'package:task_manager_app/src/core/network/dio_client.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/task/data/datasources/task_remote_data_source.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/domain/usecases/add_task_usecase.dart';
import '../../features/task/domain/usecases/delete_task_usecase.dart';
import '../../features/task/domain/usecases/get_tasks_usecase.dart';
import '../../features/task/domain/usecases/update_task_usecase.dart';
import '../../features/task/presentation/cubit/task_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. External & Core
  await _initCore();

  // 2. Network (Depends on Auth Local Source)
  await _initNetwork();

  // 3. Features
  await _initAuth();
  await _initTask();
}

Future<void> _initCore() async {
  final talker = TalkerFlutter.init();
  sl.registerSingleton<Talker>(talker);

  const secureStorage = FlutterSecureStorage();
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);
  sl.registerSingleton<AuthEventBus>(AuthEventBus());
}

Future<void> _initNetwork() async {
  // Auth Local Data Source is needed for Dio
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton<Dio>(() => DioProvider.createDio(sl(), sl(), sl()));
}

Future<void> _initAuth() async {
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Cubits
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      logoutUseCase: sl(),
      authEventBus: sl(),
    ),
  );
}

Future<void> _initTask() async {
  // Data Sources
  sl.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => TaskCubit(
      getTasks: sl(),
      addTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );
}
