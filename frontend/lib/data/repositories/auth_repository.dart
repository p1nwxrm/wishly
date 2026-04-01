import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/user_models.dart';
import '../models/token_models.dart';

// Repository for handling authentication requests
class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  // We inject both Dio and SecureStorage via GetIt
  AuthRepository(this._dio, this._storage);

  // Perform login and save tokens securely
  Future<void> login(String email, String password) async {
    try {
      // Send credentials to FastAPI using form-data
      // Note: OAuth2PasswordRequestForm strictly expects the key "username"
      final response = await _dio.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
      );

      // Parse the response using our strongly-typed TokenModel
      final tokenData = TokenModel.fromJson(response.data);

      // Validate both tokens before saving
      if (tokenData.accessToken.isNotEmpty && tokenData.refreshToken.isNotEmpty) {
        await _storage.saveAccessToken(tokenData.accessToken);
        await _storage.saveRefreshToken(tokenData.refreshToken);
      }
    } catch (e) {
      // Rethrow the error so the BLoC can handle it and show a UI message
      rethrow;
    }
  }

  // Register a new user using the strongly-typed UserCreateModel
  Future<void> register(UserCreateModel userModel) async {
    try {
      await _dio.post(
        '/users/register',
        // Dio automatically encodes Maps to JSON
        data: userModel.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile photo using MultipartFile
  // Requires the user to be logged in (token will be injected by AuthInterceptor)
  Future<void> uploadProfilePhoto(File photoFile) async {
    try {
      // Create FormData with the file
      // The key 'file' must match the parameter name in FastAPI: file: UploadFile = File(...)
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        ),
      });

      await _dio.post(
        '/users/me/photo',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Invalidate token on the backend and clear local storage
  Future<void> logout() async {
    try {
      // Send request to the backend to invalidate the current tokens
      await _dio.post('/users/logout');
    } catch (e) {
      // Ignore network errors during logout.
      // If the backend is unreachable, we still must clear local data.
    } finally {
      // Always clear local storage to ensure the user is logged out locally
      await _storage.clearAll();
    }
  }
}