part of 'wishlist_bloc.dart';

// Base class for all wishlist states
abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class WishlistInitial extends WishlistState {}

// State showing a loading indicator
class WishlistLoading extends WishlistState {}

// State showing a successfully loaded list of wishlists (for 'Me' or 'User')
class WishlistsLoaded extends WishlistState {
  final List<WishlistModel> wishlists;

  const WishlistsLoaded({required this.wishlists});

  @override
  List<Object?> get props => [wishlists];
}

// State showing a successfully loaded specific wishlist and its gifts
class WishlistDetailsLoaded extends WishlistState {
  final WishlistModel wishlist;
  final List<GiftModel> gifts;

  const WishlistDetailsLoaded({required this.wishlist, required this.gifts});

  @override
  List<Object?> get props => [wishlist, gifts];
}

// State indicating a successful one-time mutation (create, update, delete)
class WishlistActionSuccess extends WishlistState {
  final String message;

  const WishlistActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// State showing an error message
class WishlistError extends WishlistState {
  final String message;

  const WishlistError({required this.message});

  @override
  List<Object?> get props => [message];
}