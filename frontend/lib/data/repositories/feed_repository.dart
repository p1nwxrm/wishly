import 'package:dio/dio.dart';
import 'package:frontend/data/models/gift_models.dart';

// Repository for handling feed-related network requests
class FeedRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  FeedRepository(this._dio);

  // Retrieves the personalized feed for the current user with pagination support
  Future<List<SharedGiftModel>> getUserFeed({int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/feed/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      // Map the incoming JSON list to a List of FeedItemModel objects
      return (response.data as List)
          .map((json) => SharedGiftModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}