import 'package:dio/dio.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;

  AuthInterceptor(this._localDataSource);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Get the token from secure storage
    final token = await _localDataSource.getAccessToken();

    // 2. If token exists, add it to headers
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Continue the request
    handler.next(options);
  }
}
