import 'package:dio/dio.dart';
import '../models/gift_models.dart';

// Repository for handling gift booking network requests
class BookingRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  BookingRepository(this._dio);

  // Book a specific gift by its ID
  Future<void> bookGift(int giftId) async {
    try {
      await _dio.post('/bookings/$giftId');
    } catch (e) {
      rethrow;
    }
  }

  // Remove a booking for a specific gift
  Future<void> unbookGift(int giftId) async {
    try {
      await _dio.delete('/bookings/$giftId');
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve all gifts booked by the current authenticated user
  Future<List<SharedGiftModel>> getMyBookings() async {
    try {
      final response = await _dio.get('/bookings/me');
      final bookingsData = response.data['bookings'] as List;

      return bookingsData
          .map((json) => SharedGiftModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}