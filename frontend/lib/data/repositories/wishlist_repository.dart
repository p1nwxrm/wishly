import 'package:dio/dio.dart';
import '../models/wishlist_models.dart';
import '../models/gift_models.dart';

// Repository for handling wishlist-related network requests
class WishlistRepository {
  final Dio _dio;

  // We inject Dio via GetIt. Token injection is handled by AuthInterceptor.
  WishlistRepository(this._dio);

  // Create a new wishlist
  Future<WishlistModel> createWishlist(WishlistCreateModel wishlistModel) async {
    try {
      final response = await _dio.post(
        '/wishlists/',
        data: wishlistModel.toJson(),
      );

      // Convert the JSON response back into a strongly-typed model
      return WishlistModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve all wishlists for the currently logged-in user
  Future<List<WishlistModel>> getMyWishlists() async {
    try {
      final response = await _dio.get('/wishlists/me');

      // Map the incoming JSON list to a List of WishlistModel objects
      return (response.data as List)
          .map((json) => WishlistModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve a specific wishlist by its ID
  Future<WishlistModel> getWishlistById(int wishlistId) async {
    try {
      final response = await _dio.get('/wishlists/$wishlistId');
      return WishlistModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve all visible wishlists for a specific user
  Future<List<WishlistModel>> getUserWishlists(int userId) async {
    try {
      final response = await _dio.get('/wishlists/user/$userId');

      return (response.data as List)
          .map((json) => WishlistModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve all gifts belonging to a specific wishlist
  Future<List<GiftModel>> getWishlistGifts(int wishlistId) async {
    try {
      final response = await _dio.get('/wishlists/$wishlistId/gifts');

      return (response.data as List)
          .map((json) => GiftModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing wishlist (title or visibility)
  Future<WishlistModel> updateWishlist(int wishlistId, WishlistUpdateModel updateModel) async {
    try {
      final response = await _dio.patch(
        '/wishlists/$wishlistId',
        // Dio ignores null values thanks to our includeIfNull: false in the model
        data: updateModel.toJson(),
      );
      return WishlistModel.fromJson(response.data);
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