import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models/user_models.dart';
import '../models/gift_models.dart';
import '../models/wishlist_models.dart';

part 'composite_models.g.dart';

// ==========================================
// SCREEN / AGGREGATE MODELS
// Complex models aggregating data for specific application screens
// ==========================================

// Matches UserBookings in FastAPI
@JsonSerializable()
class UserBookingsModel extends Equatable {
  @JsonKey(name: 'user')
  final UserBaseModel user;

  @JsonKey(name: 'bookings', defaultValue: [])
  final List<SharedGiftModel> bookings;

  const UserBookingsModel({
    required this.user,
    this.bookings = const [],
  });

  factory UserBookingsModel.fromJson(Map<String, dynamic> json) => _$UserBookingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserBookingsModelToJson(this);

  @override
  List<Object?> get props => [user, bookings];
}

// Matches UserWishlists in FastAPI
@JsonSerializable()
class UserWishlistsModel extends Equatable {
  @JsonKey(name: 'user')
  final SocialUserModel user;

  @JsonKey(name: 'wishlists', defaultValue: [])
  final List<WishlistBaseModel> wishlists;

  const UserWishlistsModel({
    required this.user,
    this.wishlists = const [],
  });

  factory UserWishlistsModel.fromJson(Map<String, dynamic> json) => _$UserWishlistsModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserWishlistsModelToJson(this);

  @override
  List<Object?> get props => [user, wishlists];
}

// Matches UserConnections in FastAPI
@JsonSerializable()
class UserConnectionsModel extends Equatable {
  @JsonKey(name: 'user')
  final UserBaseModel user;

  @JsonKey(name: 'followers', defaultValue: [])
  final List<SocialUserModel> followers;

  @JsonKey(name: 'following', defaultValue: [])
  final List<SocialUserModel> following;

  const UserConnectionsModel({
    required this.user,
    this.followers = const [],
    this.following = const [],
  });

  factory UserConnectionsModel.fromJson(Map<String, dynamic> json) => _$UserConnectionsModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserConnectionsModelToJson(this);

  @override
  List<Object?> get props => [user, followers, following];
}