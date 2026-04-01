// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistModel _$WishlistModelFromJson(Map<String, dynamic> json) =>
    WishlistModel(
      id: (json['id'] as num).toInt(),
      ownerId: (json['owner_id'] as num).toInt(),
      title: json['title'] as String,
      isVisible: json['is_visible'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$WishlistModelToJson(WishlistModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'title': instance.title,
      'is_visible': instance.isVisible,
      'created_at': instance.createdAt.toIso8601String(),
    };

WishlistCreateModel _$WishlistCreateModelFromJson(Map<String, dynamic> json) =>
    WishlistCreateModel(
      title: json['title'] as String,
      isVisible: json['is_visible'] as bool? ?? true,
      ownerId: (json['owner_id'] as num).toInt(),
    );

Map<String, dynamic> _$WishlistCreateModelToJson(
  WishlistCreateModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'is_visible': instance.isVisible,
  'owner_id': instance.ownerId,
};

WishlistUpdateModel _$WishlistUpdateModelFromJson(Map<String, dynamic> json) =>
    WishlistUpdateModel(
      title: json['title'] as String?,
      isVisible: json['is_visible'] as bool?,
    );

Map<String, dynamic> _$WishlistUpdateModelToJson(
  WishlistUpdateModel instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'is_visible': ?instance.isVisible,
};
