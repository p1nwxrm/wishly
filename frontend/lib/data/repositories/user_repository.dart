import 'dart:io';
import 'package:dio/dio.dart';
import '../models/user_models.dart';

// Repository for handling user profile data
class UserRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  UserRepository(this._dio);

  // Retrieve the currently authenticated user's profile
  Future<PrivateUserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return PrivateUserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update the currently authenticated user's profile
  Future<PrivateUserModel> updateCurrentUser(UserUpdateModel updateModel) async {
    try {
      final response = await _dio.patch(
        '/users/me',
        // includeIfNull: false in our model ensures we only send changed fields
        data: updateModel.toJson(),
      );
      return PrivateUserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Upload the currently authenticated user's photo
  Future<PrivateUserModel> uploadProfilePhoto(File file) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/users/me/photo',
        data: formData,
      );

      return PrivateUserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile (stats, connection info) by username
  Future<UserProfileModel> getUserProfile(String username) async {
    try {
      final response = await _dio.get('/users/profile/$username');
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}