import 'package:dio/dio.dart';
import '../models/user_models.dart';

// Repository for handling user profile data
class UserRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  UserRepository(this._dio);

  // Get the currently authenticated user's profile
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Get a specific user by their ID
  Future<UserModel> getUserById(int userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update the currently authenticated user's profile
  Future<UserModel> updateCurrentUser(UserUpdateModel updateModel) async {
    try {
      final response = await _dio.patch(
        '/users/me',
        // includeIfNull: false in our model ensures we only send changed fields
        data: updateModel.toJson(),
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}