import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/user_models.dart';
import '../models/tag_models.dart';

part 'gift_models.g.dart';

// ==========================================
// 1. RESPONSE MODELS
// ==========================================

// Matches GiftBase in FastAPI
@JsonSerializable()
class GiftBaseModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'price_usd')
  final double priceUsd;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'link_url')
  final String? linkUrl;

  @JsonKey(name: 'is_visible')
  final bool isVisible;

  @JsonKey(name: 'booked_by_user_id')
  final int? bookedByUserId;

  @JsonKey(name: 'tags', defaultValue: [])
  final List<TagModel> tags;

  @JsonKey(name: 'description')
  final String? description;

  const GiftBaseModel({
    required this.id,
    required this.name,
    required this.priceUsd,
    this.photoUrl,
    this.linkUrl,
    required this.isVisible,
    this.bookedByUserId,
    this.tags = const [],
    this.description,
  });

  factory GiftBaseModel.fromJson(Map<String, dynamic> json) => _$GiftBaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GiftBaseModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    priceUsd,
    photoUrl,
    linkUrl,
    isVisible,
    bookedByUserId,
    tags,
    description,
  ];
}

// Matches SharedGift in FastAPI
@JsonSerializable()
class SharedGiftModel extends GiftBaseModel {
  @JsonKey(name: 'owner')
  final SocialUserModel owner;

  const SharedGiftModel({
    required super.id,
    required super.name,
    required super.priceUsd,
    super.photoUrl,
    super.linkUrl,
    required super.isVisible,
    super.bookedByUserId,
    super.tags = const [],
    super.description,
    required this.owner,
  });

  factory SharedGiftModel.fromJson(Map<String, dynamic> json) => _$SharedGiftModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SharedGiftModelToJson(this);

  @override
  List<Object?> get props => [...super.props, owner];
}

// ==========================================
// 2. REQUEST MODELS
// ==========================================

// Matches GiftCreate in FastAPI
@JsonSerializable()
class GiftCreateModel extends Equatable {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'price_usd')
  final double priceUsd;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'link_url')
  final String? linkUrl;

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
    this.linkUrl,
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

// Matches GiftUpdate in FastAPI (PATCH request)
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