import 'package:dio/dio.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../auth_event_bus.dart';

class TokenRefreshInterceptor extends QueuedInterceptor {
  final AuthLocalDataSource _localDataSource;
  final AuthEventBus _authEventBus;
  final Dio _dio;

  TokenRefreshInterceptor(this._localDataSource, this._authEventBus, this._dio);
  @override
  

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 1. Check if the error is 401 Unauthorized
    if (err.response?.statusCode == 401) {
      print("🔄 Token Expired. Attempting Refresh...");

      try {
        final refreshToken = await _localDataSource.getRefreshToken();

        if (refreshToken == null) {
          _authEventBus.logout();
          return handler.next(err);
        }

        final refreshDio = Dio(); 
        refreshDio.options.baseUrl = _dio.options.baseUrl; // Use same base URL
        
        final response = await refreshDio.post(
          '/auth/refresh-token',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['accessToken'];
          await _localDataSource.saveAccessToken(newAccessToken);

          print("✅ Token Refreshed Successfully!");

          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          final clonedRequest = await _dio.fetch(options);
          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        print("❌ Token Refresh Failed: $e");
        _authEventBus.logout();
      }
    }

    return handler.next(err);
  }
}
