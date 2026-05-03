import 'package:dio/dio.dart';
import '../models/wishlist_models.dart';
import '../models/composite_models.dart';

// Repository for handling wishlist-related network requests
class WishlistRepository {
  final Dio _dio;

  // We inject Dio via GetIt. Token injection is handled by AuthInterceptor.
  WishlistRepository(this._dio);

  // Create a new wishlist
  Future<WishlistBaseModel> createWishlist(WishlistCreateModel wishlistModel) async {
    try {
      final response = await _dio.post(
        '/wishlists/',
        data: wishlistModel.toJson(),
      );

      return WishlistBaseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve user profile and all their visible wishlists
  Future<UserWishlistsModel> getUserWishlists(String username) async {
    try {
      final response = await _dio.get('/wishlists/user/$username');
      return UserWishlistsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve full details of a specific wishlist, including its gifts
  Future<WishlistDetailsModel> getWishlistGifts(int wishlistId) async {
    try {
      final response = await _dio.get('/wishlists/$wishlistId/gifts');

      return WishlistDetailsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing wishlist (title or visibility)
  Future<WishlistBaseModel> updateWishlist(int wishlistId, WishlistUpdateModel updateModel) async {
    try {
      final response = await _dio.patch(
        '/wishlists/$wishlistId',
        // Dio ignores null values thanks to our includeIfNull: false in the model
        data: updateModel.toJson(),
      );

      return WishlistBaseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a wishlist
  Future<void> deleteWishlist(int wishlistId) async {
    try {
      await _dio.delete('/wishlists/$wishlistId');
    } catch (e) {
      rethrow;
    }
  }
}