// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GiftBaseModel _$GiftBaseModelFromJson(Map<String, dynamic> json) =>
    GiftBaseModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      priceUsd: (json['price_usd'] as num).toDouble(),
      photoUrl: json['photo_url'] as String?,
      linkUrl: json['link_url'] as String?,
      isVisible: json['is_visible'] as bool,
      bookedByUserId: (json['booked_by_user_id'] as num?)?.toInt(),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
    );

Map<String, dynamic> _$GiftBaseModelToJson(GiftBaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price_usd': instance.priceUsd,
      'photo_url': instance.photoUrl,
      'link_url': instance.linkUrl,
      'is_visible': instance.isVisible,
      'booked_by_user_id': instance.bookedByUserId,
      'tags': instance.tags,
      'description': instance.description,
    };

SharedGiftModel _$SharedGiftModelFromJson(Map<String, dynamic> json) =>
    SharedGiftModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      priceUsd: (json['price_usd'] as num).toDouble(),
      photoUrl: json['photo_url'] as String?,
      linkUrl: json['link_url'] as String?,
      isVisible: json['is_visible'] as bool,
      bookedByUserId: (json['booked_by_user_id'] as num?)?.toInt(),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
      owner: SocialUserModel.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SharedGiftModelToJson(SharedGiftModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price_usd': instance.priceUsd,
      'photo_url': instance.photoUrl,
      'link_url': instance.linkUrl,
      'is_visible': instance.isVisible,
      'booked_by_user_id': instance.bookedByUserId,
      'tags': instance.tags,
      'description': instance.description,
      'owner': instance.owner,
    };

GiftCreateModel _$GiftCreateModelFromJson(Map<String, dynamic> json) =>
    GiftCreateModel(
      name: json['name'] as String,
      priceUsd: (json['price_usd'] as num).toDouble(),
      linkUrl: json['link_url'] as String?,
      isVisible: json['is_visible'] as bool? ?? true,
      description: json['description'] as String?,
      wishlistId: (json['wishlist_id'] as num).toInt(),
    );

Map<String, dynamic> _$GiftCreateModelToJson(GiftCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price_usd': instance.priceUsd,
      'link_url': instance.linkUrl,
      'is_visible': instance.isVisible,
      'description': instance.description,
      'wishlist_id': instance.wishlistId,
    };

GiftUpdateModel _$GiftUpdateModelFromJson(Map<String, dynamic> json) =>
    GiftUpdateModel(
      name: json['name'] as String?,
      priceUsd: (json['price_usd'] as num?)?.toDouble(),
      linkUrl: json['link_url'] as String?,
      isVisible: json['is_visible'] as bool?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$GiftUpdateModelToJson(GiftUpdateModel instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'price_usd': ?instance.priceUsd,
      'link_url': ?instance.linkUrl,
      'is_visible': ?instance.isVisible,
      'description': ?instance.description,
    };
