import 'package:dio/dio.dart';
import '../models/gift_models.dart';
import '../models/user_models.dart';

// Repository for handling discovery-related network requests (Feed & Search)
class DiscoverRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  DiscoverRepository(this._dio);

  // Retrieves the personalized feed for the current user with pagination support
  Future<List<SharedGiftModel>> getUserFeed({int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/discover/feed',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      // Map the incoming JSON list to a List of SharedGiftModel objects
      return (response.data as List)
          .map((json) => SharedGiftModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Search for users by partial username or display name
  Future<List<SocialUserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/discover/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      // Convert the list of JSON objects into a list of SocialUserModel instances
      return (response.data as List)
          .map((json) => SocialUserModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}