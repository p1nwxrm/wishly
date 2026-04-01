import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

// Import our new local modules
import '../storage/secure_storage_service.dart';
import '../utils/app_constants.dart';
import 'auth_interceptor.dart';

// Base API client for communicating with the FastAPI backend
class ApiClient {
  late final Dio _dio;

  // We require SecureStorageService to pass it down to the AuthInterceptor
  ApiClient(SecureStorageService secureStorage) {
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
      AuthInterceptor(_dio, secureStorage),
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
          printRequestData: true,
          printResponseData: true,
        ),
      ),
    ]);
  }

  // Getter to expose the configured Dio instance
  Dio get dio => _dio;
}