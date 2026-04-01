import 'package:dio/dio.dart';
import '../models/tag_models.dart';

// Repository for handling tag-related network requests
class TagRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  TagRepository(this._dio);

  // Create a new custom tag
  Future<TagModel> createTag(TagCreateModel tagModel) async {
    try {
      final response = await _dio.post(
        '/tags/',
        data: tagModel.toJson(),
      );

      return TagModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve all tags created by the currently authenticated user
  Future<List<TagModel>> getMyTags() async {
    try {
      final response = await _dio.get('/tags/me');

      // Map the incoming JSON list to a List of TagModel objects
      return (response.data as List)
          .map((json) => TagModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve a specific tag by its ID
  Future<TagModel> getTagById(int tagId) async {
    try {
      final response = await _dio.get('/tags/$tagId');
      return TagModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update a tag's name or description
  Future<TagModel> updateTag(int tagId, TagUpdateModel updateModel) async {
    try {
      final response = await _dio.patch(
        '/tags/$tagId',
        // includeIfNull: false ensures we only send the fields that changed
        data: updateModel.toJson(),
      );
      return TagModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete an existing tag
  Future<void> deleteTag(int tagId) async {
    try {
      await _dio.delete('/tags/$tagId');
    } catch (e) {
      rethrow;
    }
  }
}