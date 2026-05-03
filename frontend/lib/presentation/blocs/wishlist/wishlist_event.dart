part of 'wishlist_bloc.dart';

// Base class for all wishlist events
abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

// Event to fetch a user's wishlists (including the current logged-in user)
class LoadUserWishlists extends WishlistEvent {
  final String username;

  const LoadUserWishlists({required this.username});

  @override
  List<Object?> get props => [username];
}

// Event to silently refresh a user's wishlists
class RefreshUserWishlists extends WishlistEvent {
  final String username;

  const RefreshUserWishlists({required this.username});

  @override
  List<Object?> get props => [username];
}

// Event to fetch a specific wishlist and its gifts
class LoadWishlistDetails extends WishlistEvent {
  final int wishlistId;

  const LoadWishlistDetails({required this.wishlistId});

  @override
  List<Object?> get props => [wishlistId];
}

// Event to silently refresh wishlist details
class RefreshWishlistDetails extends WishlistEvent {
  final int wishlistId;

  const RefreshWishlistDetails({required this.wishlistId});

  @override
  List<Object?> get props => [wishlistId];
}

// Event to create a new wishlist
class CreateWishlist extends WishlistEvent {
  final WishlistCreateModel createModel;

  const CreateWishlist({required this.createModel});

  @override
  List<Object?> get props => [createModel];
}

// Event to update an existing wishlist (title or visibility)
class UpdateWishlist extends WishlistEvent {
  final int wishlistId;
  final WishlistUpdateModel updateModel;

  const UpdateWishlist({required this.wishlistId, required this.updateModel});

  @override
  List<Object?> get props => [wishlistId, updateModel];
}

// Event to delete a wishlist
class DeleteWishlist extends WishlistEvent {
  final int wishlistId;

  const DeleteWishlist({required this.wishlistId});

  @override
  List<Object?> get props => [wishlistId];
}