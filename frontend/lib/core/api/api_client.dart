import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../storage/secure_storage_service.dart';
import '../config/config.dart';
import './auth_interceptor.dart';

// Base API client for communicating with the FastAPI backend
class ApiClient {
  late final Dio _dio;

  // We require SecureStorageService and Talker to pass them down
  ApiClient(
      SecureStorageService secureStorage,
      Talker talker, {
        required VoidCallback onUnauthorized,
      }) {
    _dio = Dio(
      BaseOptions(
        // Using our global constant for the base URL
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectionTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConstants.connectionTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors to the Dio instance
    // Note: Order matters. Auth logic runs first, then the logger prints the final request.
    _dio.interceptors.addAll([
      // Pass the callback down to the AuthInterceptor
      AuthInterceptor(
          _dio,
          secureStorage,
        onUnauthorized: onUnauthorized,
      ),
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
          printRequestData: true,
          printResponseData: false,
        ),
      ),
    ]);
  }

  // Getter to expose the configured Dio instance
  Dio get dio => _dio;
}