import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/entities/task.dart';

part 'task_remote_data_source.g.dart';

@RestApi()
abstract class TaskRemoteDataSource {
  factory TaskRemoteDataSource(Dio dio, {String baseUrl}) = _TaskRemoteDataSource;

  @GET('/tasks')
  Future<List<Task>> getTasks();

  @POST('/tasks')
  Future<Task> createTask(@Body() Map<String, dynamic> body);

  @PUT('/tasks/{id}')
  Future<Task> updateTask(@Path("id") String id, @Body() Task task);

  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path("id") String id);
}
