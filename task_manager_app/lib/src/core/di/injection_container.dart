import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

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
  // 1. External
  final talker = TalkerFlutter.init();
  sl.registerSingleton<Talker>(talker);

  final dio = DioProvider.createDio(talker);
  sl.registerSingleton<Dio>(dio);

  // 2. Data Sources
  sl.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSource(sl()));

  // 3. Repositories
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  // 4. Use Cases
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

  // 5. Cubits (Factory because they handle state)
  sl.registerFactory(
    () => TaskCubit(
      getTasks: sl(),
      addTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );
}
