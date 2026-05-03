part of 'gift_bloc.dart';

// Base class for all gift states
abstract class GiftState extends Equatable {
  const GiftState();

  @override
  List<Object?> get props => [];
}

// Initial state
class GiftInitial extends GiftState {}

// State showing a loading indicator
class GiftLoading extends GiftState {}

// State showing the successfully loaded details of a gift
class GiftLoaded extends GiftState {
  final SharedGiftModel sharedGift;

  const GiftLoaded({required this.sharedGift});

  @override
  List<Object?> get props => [sharedGift];
}

// State indicating a successful mutation (create, update, delete)
// Useful for the UI to know when to navigate back or show a success toast
class GiftActionSuccess extends GiftState {
  final String message;

  const GiftActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// State showing an error message
class GiftError extends GiftState {
  final String message;

  const GiftError({required this.message});

  @override
  List<Object?> get props => [message];
}