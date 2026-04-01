import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wishlist_models.g.dart';

// ==========================================
// WISHLIST RESPONSE MODEL
// Matches WishlistResponse in FastAPI
// ==========================================
@JsonSerializable()
class WishlistModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'owner_id')
  final int ownerId;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'is_visible')
  final bool isVisible;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const WishlistModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.isVisible,
    required this.createdAt,
  });

  // Factory constructor for generating a new instance from a JSON map
  factory WishlistModel.fromJson(Map<String, dynamic> json) => _$WishlistModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$WishlistModelToJson(this);

  @override
  List<Object?> get props => [id, ownerId, title, isVisible, createdAt];
}

// ==========================================
// WISHLIST CREATE MODEL
// Matches WishlistCreate in FastAPI
// ==========================================
@JsonSerializable()
class WishlistCreateModel extends Equatable {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'is_visible')
  final bool isVisible;

  @JsonKey(name: 'owner_id')
  final int ownerId;

  const WishlistCreateModel({
    required this.title,
    this.isVisible = true,
    required this.ownerId,
  });

  factory WishlistCreateModel.fromJson(Map<String, dynamic> json) => _$WishlistCreateModelFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistCreateModelToJson(this);

  @override
  List<Object?> get props => [title, isVisible, ownerId];
}

// ==========================================
// WISHLIST UPDATE MODEL
// Matches WishlistUpdate in FastAPI (PATCH request)
// ==========================================
// includeIfNull: false ensures we don't send null fields to the backend
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

  factory WishlistUpdateModel.fromJson(Map<String, dynamic> json) => _$WishlistUpdateModelFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistUpdateModelToJson(this);

  @override
  List<Object?> get props => [title, isVisible];
}