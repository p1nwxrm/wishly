part of 'booking_bloc.dart';

// Base class for all booking events
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

// Event to fetch the list of gifts booked by the current user
class LoadMyBookings extends BookingEvent {
  final bool isRefresh;

  const LoadMyBookings({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

// Event to book a specific gift
class BookGift extends BookingEvent {
  final int giftId;

  const BookGift({required this.giftId});

  @override
  List<Object?> get props => [giftId];
}

// Event to remove a booking from a specific gift
class UnbookGift extends BookingEvent {
  final int giftId;

  const UnbookGift({required this.giftId});

  @override
  List<Object?> get props => [giftId];
}