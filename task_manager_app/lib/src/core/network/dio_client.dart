import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import 'auth_event_bus.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/token_refresh_interceptor.dart';

class DioProvider {
  static Dio createDio({
   required Talker talker,
   required AuthLocalDataSource authDataSource,
  required  AuthEventBus authEventBus,
  }) {
    final dio = Dio();

    // 1. Determine Base URL
    final String baseUrl = Platform.isAndroid
        ? 'http://10.0.2.2:3000'
        : 'http://127.0.0.1:3000';

    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    

    // 2. Add Auth Interceptors
    dio.interceptors.add(AuthInterceptor(authDataSource));
    dio.interceptors.add(TokenRefreshInterceptor(authDataSource, authEventBus, dio));

    // 3. Add Logger
    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
        ),
      ),
    );

    return dio;
  }
}
