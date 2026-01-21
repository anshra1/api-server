import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_response_model.dart';

part 'auth_remote_data_source.g.dart';

/// Retrofit client for auth API
@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) = _AuthRemoteDataSource;

  /// Register a new user
  @POST('/auth/register')
  Future<AuthResponseModel> register(@Body() Map<String, dynamic> body);

  /// Login with email and password
  @POST('/auth/login')
  Future<AuthResponseModel> login(@Body() Map<String, dynamic> body);

  /// Change password (requires authenticated Dio)
  @PUT('/auth/change-password')
  Future<void> changePassword(@Body() Map<String, dynamic> body);
}
