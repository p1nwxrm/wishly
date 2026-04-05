part of 'booking_bloc.dart';

// Base class for all booking states
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class BookingInitial extends BookingState {}

// State showing a loading indicator
class BookingLoading extends BookingState {}

// State showing the successfully loaded list of bookings
class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;

  const BookingsLoaded({required this.bookings});

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