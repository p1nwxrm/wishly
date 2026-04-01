import 'package:dio/dio.dart';
import '../models/booking_models.dart';

// Repository for handling gift booking network requests
class BookingRepository {
  final Dio _dio;

  // Inject Dio via GetIt
  BookingRepository(this._dio);

  // Book a specific gift by its ID
  Future<BookingModel> bookGift(int giftId) async {
    try {
      final response = await _dio.post('/bookings/$giftId');
      return BookingModel.fromJson(response.data);
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
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get('/bookings/me');

      // Map the incoming JSON list to a List of BookingModel objects
      return (response.data as List)
          .map((json) => BookingModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}