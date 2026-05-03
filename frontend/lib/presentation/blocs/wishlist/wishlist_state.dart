part of 'wishlist_bloc.dart';

// Base class for all wishlist states
abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class WishlistInitial extends WishlistState {}

// State showing a full-screen loading indicator
class WishlistLoading extends WishlistState {}

// State showing a successfully loaded profile and list of wishlists
class UserWishlistsLoaded extends WishlistState {
  final UserWishlistsModel data;

  const UserWishlistsLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

// State showing a successfully loaded specific wishlist and its gifts combined
class WishlistDetailsLoaded extends WishlistState {
  final WishlistDetailsModel wishlistDetails;

  const WishlistDetailsLoaded({required this.wishlistDetails});

  @override
  List<Object?> get props => [wishlistDetails];
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