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

  // Get a list of users who are following the current user
  Future<List<UserSubscriptionModel>> getMyFollowers() async {
    try {
      final response = await _dio.get('/subscriptions/followers/me');

      // Map the incoming JSON list to a List of UserSubscriptionModel objects
      return (response.data as List)
          .map((json) => UserSubscriptionModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get a list of users that the current user is following
  Future<List<UserSubscriptionModel>> getMyFollowing() async {
    try {
      final response = await _dio.get('/subscriptions/following/me');

      // Map the incoming JSON list to a List of UserSubscriptionModel objects
      return (response.data as List)
          .map((json) => UserSubscriptionModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}