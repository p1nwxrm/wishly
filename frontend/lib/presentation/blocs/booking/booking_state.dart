part of 'booking_bloc.dart';

// Base class for all booking states
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class BookingInitial extends BookingState {}

// State showing a loading indicator for the entire list of bookings (e.g., full screen)
class BookingsListLoading extends BookingState {}

// State showing a loading indicator for a specific gift action (button-level loading)
class BookingGiftLoading extends BookingState {
  final int giftId;

  const BookingGiftLoading({required this.giftId});

  @override
  List<Object?> get props => [giftId];
}

// State showing the successfully loaded list of bookings
class BookingsListLoaded extends BookingState {
  final List<SharedGiftModel> bookings;

  const BookingsListLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

// State indicating a successful one-time mutation (book/unbook)
class BookingActionSuccess extends BookingState {
  final String message;

  const BookingActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// State showing an error message
class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}