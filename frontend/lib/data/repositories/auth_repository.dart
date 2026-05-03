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
      final tokenData = TokenSetModel.fromJson(response.data);

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
  Future<PrivateUserModel> register(UserCreateModel userModel) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        // Dio automatically encodes Maps to JSON
        data: userModel.toJson(),
      );

      // FastAPI returns the created PrivateUser
      return PrivateUserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile photo using MultipartFile
  // Note: Architecturally, this could live in UserRepository, but kept here for now.
  Future<PrivateUserModel> uploadProfilePhoto(File photoFile) async {
    try {
      // Create FormData with the file
      // The key 'file' must match the parameter name in FastAPI: file: UploadFile = File(...)
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/users/me/photo',
        data: formData,
      );

      // FastAPI returns the updated PrivateUser
      return PrivateUserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Silently wipe tokens from the device without pinging the backend
  Future<void> clearLocalSession() async {
    await _storage.clearAll();
  }

  // Invalidate token on the backend and clear local storage
  Future<void> logout() async {
    try {
      // Send request to the backend to invalidate the current tokens
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignore network errors during logout.
      // If the backend is unreachable, we still must clear local data.
    } finally {
      // Always clear local storage to ensure the user is logged out locally
      await clearLocalSession();
    }
  }

  // Check if a valid access token exists in storage
  Future<bool> hasValidToken() async {
    try {
      final token = await _storage.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Perform a real network request to verify if the session is alive
  Future<PrivateUserModel> verifySession() async {
    try {
      // We hit a protected endpoint.
      // If the token is expired, AuthInterceptor will automatically try to refresh it.
      // If refresh fails, it will throw a DioException.
      final response = await _dio.get('/users/me');

      // Parse the response into our strongly-typed PrivateUserModel
      return PrivateUserModel.fromJson(response.data);
    } catch (e) {
      // If the request completely fails (e.g., both tokens are dead),
      // ensure we clean up local storage and rethrow the error for the BLoC.
      await clearLocalSession();
      rethrow;
    }
  }
}