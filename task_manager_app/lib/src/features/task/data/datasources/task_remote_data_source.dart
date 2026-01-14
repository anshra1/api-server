import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/task_model.dart';

part 'task_remote_data_source.g.dart';

@RestApi()
abstract class TaskRemoteDataSource {
  factory TaskRemoteDataSource(Dio dio, {String baseUrl}) = _TaskRemoteDataSource;

  @GET('/tasks')
  Future<List<TaskModel>> getTasks();

  @POST('/tasks')
  Future<TaskModel> createTask(@Body() Map<String, dynamic> body);

  @PUT('/tasks/{id}')
  Future<TaskModel> updateTask(@Path("id") String id, @Body() TaskModel task);

  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path("id") String id);
}