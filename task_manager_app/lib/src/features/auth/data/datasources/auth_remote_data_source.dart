import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseModel> login(String username, String password) async {
    // Note: We use the injected Dio instance. 
    // Ideally, for Login, we might want a Dio instance WITHOUT the AuthInterceptor 
    // to avoid sending a potentially invalid old token, but sending it is usually harmless 
    // or we can use a fresh Dio instance or specific options. 
    // For now, using the main _dio is fine as the server likely ignores the header for /login.
    
    final response = await _dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password, // Our fake server ignores this, but real one wouldn't
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }
}
