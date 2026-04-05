import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../../data/models/booking_models.dart';
import '../../../core/api/api_error_parser.dart';
import '../../../data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

// Bloc responsible for managing gift booking logic
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc(this._bookingRepository) : super(BookingInitial()) {
    on<LoadMyBookings>(_onLoadMyBookings);
    on<BookGift>(_onBookGift);
    on<UnbookGift>(_onUnbookGift);
  }

  // Handle fetching the list of my bookings
  Future<void> _onLoadMyBookings(
      LoadMyBookings event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());
    try {
      final bookings = await _bookingRepository.getMyBookings();
      emit(BookingsLoaded(bookings: bookings));
    } on DioException catch (e) {
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(BookingError(message: errorMsg));
    } catch (e) {
      emit(const BookingError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle booking a specific gift
  Future<void> _onBookGift(
      BookGift event,
      Emitter<BookingState> emit,
      ) async {
    try {
      await _bookingRepository.bookGift(event.giftId);

      // Notify UI about the successful booking
      emit(const BookingActionSuccess(message: 'Gift successfully booked!'));

      // Reload the bookings list to reflect the new state
      add(LoadMyBookings());
    } on DioException catch (e) {
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(BookingError(message: errorMsg));
    } catch (e) {
      emit(const BookingError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle unbooking a specific gift
  Future<void> _onUnbookGift(
      UnbookGift event,
      Emitter<BookingState> emit,
      ) async {
    try {
      await _bookingRepository.unbookGift(event.giftId);

      // Notify UI about the successful unbooking
      emit(const BookingActionSuccess(message: 'Booking successfully removed.'));

      // Reload the bookings list to reflect the new state
      add(LoadMyBookings());
    } on DioException catch (e) {
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(BookingError(message: errorMsg));
    } catch (e) {
      emit(const BookingError(message: 'An unexpected error occurred.'));
    }
  }
}