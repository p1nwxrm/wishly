// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composite_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBookingsModel _$UserBookingsModelFromJson(Map<String, dynamic> json) =>
    UserBookingsModel(
      user: UserBaseModel.fromJson(json['user'] as Map<String, dynamic>),
      bookings:
          (json['bookings'] as List<dynamic>?)
              ?.map((e) => SharedGiftModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$UserBookingsModelToJson(UserBookingsModel instance) =>
    <String, dynamic>{'user': instance.user, 'bookings': instance.bookings};

UserWishlistsModel _$UserWishlistsModelFromJson(Map<String, dynamic> json) =>
    UserWishlistsModel(
      user: SocialUserModel.fromJson(json['user'] as Map<String, dynamic>),
      wishlists:
          (json['wishlists'] as List<dynamic>?)
              ?.map(
                (e) => WishlistBaseModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$UserWishlistsModelToJson(UserWishlistsModel instance) =>
    <String, dynamic>{'user': instance.user, 'wishlists': instance.wishlists};

UserConnectionsModel _$UserConnectionsModelFromJson(
  Map<String, dynamic> json,
) => UserConnectionsModel(
  user: UserBaseModel.fromJson(json['user'] as Map<String, dynamic>),
  followers:
      (json['followers'] as List<dynamic>?)
          ?.map((e) => SocialUserModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  following:
      (json['following'] as List<dynamic>?)
          ?.map((e) => SocialUserModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$UserConnectionsModelToJson(
  UserConnectionsModel instance,
) => <String, dynamic>{
  'user': instance.user,
  'followers': instance.followers,
  'following': instance.following,
};
