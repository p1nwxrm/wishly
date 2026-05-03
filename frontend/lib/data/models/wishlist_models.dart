import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/user_models.dart';
import '../models/gift_models.dart';

part 'wishlist_models.g.dart';

// ==========================================
// 1. RESPONSE MODELS
// ==========================================

// Matches WishlistBase in FastAPI
@JsonSerializable()
class WishlistBaseModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'gifts_count', defaultValue: 0)
  final int giftsCount;

  @JsonKey(name: 'is_visible')
  final bool isVisible;

  const WishlistBaseModel({
    required this.id,
    required this.title,
    this.giftsCount = 0,
    required this.isVisible,
  });

  factory WishlistBaseModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistBaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishlistBaseModelToJson(this);

  @override
  List<Object?> get props => [id, title, giftsCount, isVisible];
}

// Matches SharedWishlist in FastAPI
@JsonSerializable()
class SharedWishlistModel extends WishlistBaseModel {
  @JsonKey(name: 'owner')
  final SocialUserModel owner;

  const SharedWishlistModel({
    required super.id,
    required super.title,
    super.giftsCount = 0,
    required super.isVisible,
    required this.owner,
  });

  factory SharedWishlistModel.fromJson(Map<String, dynamic> json) =>
      _$SharedWishlistModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SharedWishlistModelToJson(this);

  @override
  List<Object?> get props => [...super.props, owner];
}

// Matches WishlistDetails in FastAPI
@JsonSerializable()
class WishlistDetailsModel extends SharedWishlistModel {
  @JsonKey(name: 'gifts', defaultValue: [])
  final List<GiftBaseModel> gifts;

  const WishlistDetailsModel({
    required super.id,
    required super.title,
    super.giftsCount = 0,
    required super.isVisible,
    required super.owner,
    this.gifts = const [],
  });

  factory WishlistDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistDetailsModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WishlistDetailsModelToJson(this);

  @override
  List<Object?> get props => [...super.props, gifts];
}

// ==========================================
// 2. REQUEST MODELS
// ==========================================

// Matches WishlistCreate in FastAPI
@JsonSerializable()
class WishlistCreateModel extends Equatable {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'is_visible')
  final bool isVisible;

  const WishlistCreateModel({
    required this.title,
    this.isVisible = true,
  });

  factory WishlistCreateModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishlistCreateModelToJson(this);

  @override
  List<Object?> get props => [title, isVisible];
}

// Matches WishlistUpdate in FastAPI (PATCH request)
@JsonSerializable(includeIfNull: false)
class WishlistUpdateModel extends Equatable {
  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'is_visible')
  final bool? isVisible;

  const WishlistUpdateModel({
    this.title,
    this.isVisible,
  });

  factory WishlistUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishlistUpdateModelToJson(this);

  @override
  List<Object?> get props => [title, isVisible];
}