import 'dart:io';
import 'package:dio/dio.dart';
import '../models/gift_models.dart';

// Repository for handling gift-related network requests
class GiftRepository {
  final Dio _dio;

  // We inject Dio via GetIt. Token injection is handled by AuthInterceptor.
  GiftRepository(this._dio);

  // Create a new gift in a specific wishlist
  Future<SharedGiftModel> createGift(GiftCreateModel giftModel) async {
    try {
      final response = await _dio.post(
        '/gifts/',
        data: giftModel.toJson(),
      );

      return SharedGiftModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Upload a photo for a specific gift
  Future<SharedGiftModel> uploadGiftPhoto(int giftId, File photoFile) async {
    try {
      // Create FormData with the file
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/gifts/$giftId/photo',
        data: formData,
      );

      return SharedGiftModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve a specific gift by its ID
  Future<SharedGiftModel> getSharedGiftById(int giftId) async {
    try {
      final response = await _dio.get('/gifts/$giftId');
      return SharedGiftModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing gift (e.g., change price, name, or visibility)
  Future<SharedGiftModel> updateGift(int giftId, GiftUpdateModel updateModel) async {
    try {
      final response = await _dio.patch(
        '/gifts/$giftId',
        // Dio ignores null values thanks to includeIfNull: false in the model
        data: updateModel.toJson(),
      );

      return SharedGiftModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a specific gift
  Future<void> deleteGift(int giftId) async {
    try {
      await _dio.delete('/gifts/$giftId');
    } catch (e) {
      rethrow;
    }
  }
}