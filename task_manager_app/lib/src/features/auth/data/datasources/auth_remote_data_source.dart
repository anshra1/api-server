import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_response_model.dart';

/// Abstract interface for auth remote data source
abstract class AuthRemoteDataSource {
  /// Register a new user
  Future<AuthResponseModel> register(String email, String password, String name);

  /// Login with email and password
  Future<AuthResponseModel> login(String email, String password);

  /// Change password (requires authenticated Dio)
  Future<void> changePassword(String currentPassword, String newPassword);
}

/// Implementation of auth remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseModel> register(String email, String password, String name) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    // Note: We use the injected Dio instance.
    // For Login, the server validates email/password and returns tokens.

    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _dio.put(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
