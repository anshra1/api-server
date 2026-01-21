import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? name, String? picture});
  Future<void> deleteAccount(String password);
  Future<Map<String, dynamic>> getAccountStats();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.userProfile);
    // Server returns the user object directly: { id, name, email, ... }
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> updateProfile({String? name, String? picture}) async {
    final response = await _dio.put(
      ApiEndpoints.userProfile,
      data: {
        if (name != null) 'name': name,
        if (picture != null) 'picture': picture,
      },
    );
    // Server returns the updated user object directly
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> deleteAccount(String password) async {
    await _dio.delete(
      ApiEndpoints.userProfile,
      data: {'password': password},
    );
  }

  @override
  Future<Map<String, dynamic>> getAccountStats() async {
    final response = await _dio.get(ApiEndpoints.userStats);
    // Server returns { user: {...}, tasks: {...} }
    return response.data;
  }
}
