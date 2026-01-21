import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:task_manager_app/src/core/constants/api_endpoints.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import 'auth_event_bus.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/correlation_id_interceptor.dart';
import 'interceptors/error_mapping_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/token_refresh_interceptor.dart';

class DioProvider {
  static Dio createDio({
    required Talker talker,
    required AuthLocalDataSource authDataSource,
    required AuthEventBus authEventBus,
  }) {
    final dio = Dio();

    // 1. Configure Base Options
    final String serverAPIbaseUrl = Platform.isAndroid
        ? ApiEndpoints.baseUrlAndroid
        : ApiEndpoints.baseUrlLocal;

    dio.options.baseUrl = serverAPIbaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    // 2. Add Interceptors (ORDER MATTERS!)
    // The interceptor chain processes requests top-to-bottom,
    // and responses/errors bottom-to-top.
    dio.interceptors.addAll([
      // 1. Add correlation ID for request tracing
      CorrelationIdInterceptor(),

      // 2. Attach auth token to requests
      AuthInterceptor(authDataSource),

      // 3. Retry failed requests (timeouts, 5xx errors)
      RetryInterceptor(dio: dio),

      // 4. Handle 401 and refresh token
      TokenRefreshInterceptor(authDataSource, authEventBus, dio),

      // 5. Map errors to NetworkException
      ErrorMappingInterceptor(),

      // 6. Log requests/responses (dev only)
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
        ),
      ),
    ]);

    return dio;
  }
}
