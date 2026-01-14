import 'dart:io';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class DioProvider {
  static Dio createDio(Talker talker) {
    final dio = Dio();

    // 1. Determine Base URL
    final String baseUrl = Platform.isAndroid 
        ? 'http://10.0.2.2:3000' 
        : 'http://127.0.0.1:3000';
    
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true, 
          printResponseMessage: true,
        ),
      ),
    );

    return dio;
  }
}
