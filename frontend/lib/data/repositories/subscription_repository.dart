import 'package:dio/dio.dart';
import '../models/user_subscription_models.dart';

// Repository for handling user followers and following logic
class SubscriptionRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  SubscriptionRepository(this._dio);

  // Subscribe to (follow) another user
  Future<void> followUser(int targetUserId) async {
    try {
      // The target ID is passed directly in the URL path
      await _dio.post('/subscriptions/$targetUserId');
    } catch (e) {
      rethrow;
    }
  }

  // Unsubscribe from (unfollow) another user
  Future<void> unfollowUser(int targetUserId) async {
    try {
      // The target ID is passed directly in the URL path
      await _dio.delete('/subscriptions/$targetUserId');
    } catch (e) {
      rethrow;
    }
  }

  // Get a list of users who are following a specific user
  Future<List<UserConnectionModel>> getUserFollowers(int userId) async {
    try {
      final response = await _dio.get('/subscriptions/followers/$userId');

      // Map the incoming JSON list to a List of UserConnectionModel objects
      return (response.data as List)
          .map((json) => UserConnectionModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get a list of users that a specific user is following
  Future<List<UserConnectionModel>> getUserFollowing(int userId) async {
    try {
      final response = await _dio.get('/subscriptions/following/$userId');

      // Map the incoming JSON list to a List of UserConnectionModel objects
      return (response.data as List)
          .map((json) => UserConnectionModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}