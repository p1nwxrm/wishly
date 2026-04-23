import 'package:dio/dio.dart';
import '../models/user_models.dart';
import '../models/user_subscription_models.dart';

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

  // Get user profile (stats, connection info) by username
  Future<UserProfileModel> getUserProfile(String username) async {
    try {
      final response = await _dio.get('/users/$username');
      return UserProfileModel.fromJson(response.data);
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

  // Search for users by partial username or display name
  Future<List<UserConnectionModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/users/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      // Convert the list of JSON objects into a list of UserModel instances
      return (response.data as List)
          .map((json) => UserConnectionModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}