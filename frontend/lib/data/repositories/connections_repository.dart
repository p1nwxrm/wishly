import 'package:dio/dio.dart';
import '../models/user_models.dart';
import '../models/composite_models.dart';

// Repository for handling user connections (followers and following logic)
class ConnectionsRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  ConnectionsRepository(this._dio);

  // Subscribe to (follow) another user by username
  Future<void> followUser(String targetUsername) async {
    try {
      await _dio.post('/connections/$targetUsername');
    } catch (e) {
      rethrow;
    }
  }

  // Unsubscribe from (unfollow) another user by username
  Future<void> unfollowUser(String targetUsername) async {
    try {
      await _dio.delete('/connections/$targetUsername');
    } catch (e) {
      rethrow;
    }
  }

  // Get a list of users who are following a specific user
  Future<List<SocialUserModel>> getUserFollowers(String targetUsername) async {
    try {
      final response = await _dio.get('/connections/$targetUsername/followers');

      // Map the incoming JSON list to a List of SocialUserModel objects
      return (response.data as List)
          .map((json) => SocialUserModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get a list of users that a specific user is following
  Future<List<SocialUserModel>> getUserFollowing(String targetUsername) async {
    try {
      final response = await _dio.get('/connections/$targetUsername/following');

      // Map the incoming JSON list to a List of SocialUserModel objects
      return (response.data as List)
          .map((json) => SocialUserModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Retrieves the complete network (followers and following) for a user
  // Designed to power a unified 'Connections' screen in a single API call
  Future<UserConnectionsModel> getConnectionSummary(String targetUsername) async {
    try {
      final response = await _dio.get('/connections/$targetUsername/summary');

      return UserConnectionsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}