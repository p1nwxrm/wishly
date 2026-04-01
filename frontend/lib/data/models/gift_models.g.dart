// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GiftModel _$GiftModelFromJson(Map<String, dynamic> json) => GiftModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  priceUsd: (json['price_usd'] as num).toDouble(),
  photoUrl: json['photo_url'] as String?,
  linkUrl: json['link_url'] as String,
  isVisible: json['is_visible'] as bool,
  description: json['description'] as String?,
  wishlistId: (json['wishlist_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GiftModelToJson(GiftModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price_usd': instance.priceUsd,
  'photo_url': instance.photoUrl,
  'link_url': instance.linkUrl,
  'is_visible': instance.isVisible,
  'description': instance.description,
  'wishlist_id': instance.wishlistId,
  'created_at': instance.createdAt.toIso8601String(),
};

GiftCreateModel _$GiftCreateModelFromJson(Map<String, dynamic> json) =>
    GiftCreateModel(
      name: json['name'] as String,
      priceUsd: (json['price_usd'] as num).toDouble(),
      photoUrl: json['photo_url'] as String?,
      linkUrl: json['link_url'] as String,
      isVisible: json['is_visible'] as bool? ?? true,
      description: json['description'] as String?,
      wishlistId: (json['wishlist_id'] as num).toInt(),
    );

Map<String, dynamic> _$GiftCreateModelToJson(GiftCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price_usd': instance.priceUsd,
      'photo_url': instance.photoUrl,
      'link_url': instance.linkUrl,
      'is_visible': instance.isVisible,
      'description': instance.description,
      'wishlist_id': instance.wishlistId,
    };

GiftUpdateModel _$GiftUpdateModelFromJson(Map<String, dynamic> json) =>
    GiftUpdateModel(
      name: json['name'] as String?,
      priceUsd: (json['price_usd'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      linkUrl: json['link_url'] as String?,
      isVisible: json['is_visible'] as bool?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$GiftUpdateModelToJson(GiftUpdateModel instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'price_usd': ?instance.priceUsd,
      'photo_url': ?instance.photoUrl,
      'link_url': ?instance.linkUrl,
      'is_visible': ?instance.isVisible,
      'description': ?instance.description,
    };
