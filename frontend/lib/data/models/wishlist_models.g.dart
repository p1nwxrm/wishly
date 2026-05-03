// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistBaseModel _$WishlistBaseModelFromJson(Map<String, dynamic> json) =>
    WishlistBaseModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      giftsCount: (json['gifts_count'] as num?)?.toInt() ?? 0,
      isVisible: json['is_visible'] as bool,
    );

Map<String, dynamic> _$WishlistBaseModelToJson(WishlistBaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'gifts_count': instance.giftsCount,
      'is_visible': instance.isVisible,
    };

SharedWishlistModel _$SharedWishlistModelFromJson(Map<String, dynamic> json) =>
    SharedWishlistModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      giftsCount: (json['gifts_count'] as num?)?.toInt() ?? 0,
      isVisible: json['is_visible'] as bool,
      owner: SocialUserModel.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SharedWishlistModelToJson(
  SharedWishlistModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'gifts_count': instance.giftsCount,
  'is_visible': instance.isVisible,
  'owner': instance.owner,
};

WishlistDetailsModel _$WishlistDetailsModelFromJson(
  Map<String, dynamic> json,
) => WishlistDetailsModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  giftsCount: (json['gifts_count'] as num?)?.toInt() ?? 0,
  isVisible: json['is_visible'] as bool,
  owner: SocialUserModel.fromJson(json['owner'] as Map<String, dynamic>),
  gifts:
      (json['gifts'] as List<dynamic>?)
          ?.map((e) => GiftBaseModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$WishlistDetailsModelToJson(
  WishlistDetailsModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'gifts_count': instance.giftsCount,
  'is_visible': instance.isVisible,
  'owner': instance.owner,
  'gifts': instance.gifts,
};

WishlistCreateModel _$WishlistCreateModelFromJson(Map<String, dynamic> json) =>
    WishlistCreateModel(
      title: json['title'] as String,
      isVisible: json['is_visible'] as bool? ?? true,
    );

Map<String, dynamic> _$WishlistCreateModelToJson(
  WishlistCreateModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'is_visible': instance.isVisible,
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
