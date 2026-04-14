import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../core/api/api_error_parser.dart';
import '../../../data/models/gift_models.dart';
import '../../../data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

// Bloc responsible for managing gift booking logic
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;
  final Talker _talker;

  BookingBloc(this._bookingRepository, this._talker) : super(BookingInitial()) {
    on<LoadMyBookings>(_onLoadMyBookings);
    on<BookGift>(_onBookGift);
    on<UnbookGift>(_onUnbookGift);
  }

  // Handle fetching the list of my bookings
  Future<void> _onLoadMyBookings(
      LoadMyBookings event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingsListLoading());
    try {
      final bookings = await _bookingRepository.getMyBookings();
      emit(BookingsListLoaded(bookings: bookings));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(BookingError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const BookingError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle booking a specific gift
  Future<void> _onBookGift(
      BookGift event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading(giftId: event.giftId));

    try {
      await _bookingRepository.bookGift(event.giftId);

      // Notify UI about the successful booking
      emit(const BookingActionSuccess(message: 'Gift successfully booked!'));

      // Removed add(LoadMyBookings()) to prevent unnecessary network requests
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(BookingError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const BookingError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle unbooking a specific gift
  Future<void> _onUnbookGift(
      UnbookGift event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading(giftId: event.giftId));

    try {
      await _bookingRepository.unbookGift(event.giftId);

      // Notify UI about the successful unbooking
      emit(const BookingActionSuccess(message: 'Booking successfully removed.'));

      // Removed add(LoadMyBookings()) to prevent unnecessary network requests
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(BookingError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const BookingError(message: 'An unexpected error occurred.'));
    }
  }
}