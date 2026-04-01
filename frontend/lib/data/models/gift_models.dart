import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gift_models.g.dart';

// ==========================================
// GIFT RESPONSE MODEL
// Matches GiftResponse in FastAPI
// ==========================================
@JsonSerializable()
class GiftModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'price_usd')
  final double priceUsd;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'link_url')
  final String linkUrl;

  @JsonKey(name: 'is_visible')
  final bool isVisible;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'wishlist_id')
  final int wishlistId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const GiftModel({
    required this.id,
    required this.name,
    required this.priceUsd,
    this.photoUrl,
    required this.linkUrl,
    required this.isVisible,
    this.description,
    required this.wishlistId,
    required this.createdAt,
  });

  // Factory constructor for generating a new instance from a JSON map
  factory GiftModel.fromJson(Map<String, dynamic> json) => _$GiftModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$GiftModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    priceUsd,
    photoUrl,
    linkUrl,
    isVisible,
    description,
    wishlistId,
    createdAt,
  ];
}

// ==========================================
// GIFT CREATE MODEL
// Matches GiftCreate in FastAPI
// ==========================================
@JsonSerializable()
class GiftCreateModel extends Equatable {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'price_usd')
  final double priceUsd;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'link_url')
  final String linkUrl;

  @JsonKey(name: 'is_visible')
  final bool isVisible;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'wishlist_id')
  final int wishlistId;

  const GiftCreateModel({
    required this.name,
    required this.priceUsd,
    this.photoUrl,
    required this.linkUrl,
    this.isVisible = true,
    this.description,
    required this.wishlistId,
  });

  factory GiftCreateModel.fromJson(Map<String, dynamic> json) => _$GiftCreateModelFromJson(json);
  Map<String, dynamic> toJson() => _$GiftCreateModelToJson(this);

  @override
  List<Object?> get props => [
    name,
    priceUsd,
    photoUrl,
    linkUrl,
    isVisible,
    description,
    wishlistId,
  ];
}

// ==========================================
// GIFT UPDATE MODEL
// Matches GiftUpdate in FastAPI (PATCH request)
// ==========================================
// includeIfNull: false ensures we don't send null fields to the backend
@JsonSerializable(includeIfNull: false)
class GiftUpdateModel extends Equatable {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'price_usd')
  final double? priceUsd;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'link_url')
  final String? linkUrl;

  @JsonKey(name: 'is_visible')
  final bool? isVisible;

  @JsonKey(name: 'description')
  final String? description;

  const GiftUpdateModel({
    this.name,
    this.priceUsd,
    this.photoUrl,
    this.linkUrl,
    this.isVisible,
    this.description,
  });

  factory GiftUpdateModel.fromJson(Map<String, dynamic> json) => _$GiftUpdateModelFromJson(json);
  Map<String, dynamic> toJson() => _$GiftUpdateModelToJson(this);

  @override
  List<Object?> get props => [
    name,
    priceUsd,
    photoUrl,
    linkUrl,
    isVisible,
    description,
  ];
}