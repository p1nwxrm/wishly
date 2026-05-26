// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) =>
    UserStatsModel(
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserStatsModelToJson(UserStatsModel instance) =>
    <String, dynamic>{
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
    };

UserRelationshipModel _$UserRelationshipModelFromJson(
  Map<String, dynamic> json,
) => UserRelationshipModel(
  isFollowing: json['is_following'] as bool? ?? false,
  isFollower: json['is_follower'] as bool? ?? false,
);

Map<String, dynamic> _$UserRelationshipModelToJson(
  UserRelationshipModel instance,
) => <String, dynamic>{
  'is_following': instance.isFollowing,
  'is_follower': instance.isFollower,
};

UserBaseModel _$UserBaseModelFromJson(Map<String, dynamic> json) =>
    UserBaseModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      name: json['name'] as String,
      subscriptionType: SubscriptionPlanModel.fromJson(
        json['subscription_type'] as Map<String, dynamic>,
      ),
      photoUrl: json['photo_url'] as String?,
    );

Map<String, dynamic> _$UserBaseModelToJson(UserBaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'subscription_type': instance.subscriptionType,
      'photo_url': instance.photoUrl,
    };

PrivateUserModel _$PrivateUserModelFromJson(Map<String, dynamic> json) =>
    PrivateUserModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      name: json['name'] as String,
      subscriptionType: SubscriptionPlanModel.fromJson(
        json['subscription_type'] as Map<String, dynamic>,
      ),
      photoUrl: json['photo_url'] as String?,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PrivateUserModelToJson(PrivateUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'subscription_type': instance.subscriptionType,
      'photo_url': instance.photoUrl,
      'email': instance.email,
      'created_at': instance.createdAt.toIso8601String(),
    };

SocialUserModel _$SocialUserModelFromJson(Map<String, dynamic> json) =>
    SocialUserModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      name: json['name'] as String,
      subscriptionType: SubscriptionPlanModel.fromJson(
        json['subscription_type'] as Map<String, dynamic>,
      ),
      photoUrl: json['photo_url'] as String?,
      relationship: json['relationship'] == null
          ? null
          : UserRelationshipModel.fromJson(
              json['relationship'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SocialUserModelToJson(SocialUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'subscription_type': instance.subscriptionType,
      'photo_url': instance.photoUrl,
      'relationship': instance.relationship,
    };

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      name: json['name'] as String,
      subscriptionType: SubscriptionPlanModel.fromJson(
        json['subscription_type'] as Map<String, dynamic>,
      ),
      photoUrl: json['photo_url'] as String?,
      relationship: json['relationship'] == null
          ? null
          : UserRelationshipModel.fromJson(
              json['relationship'] as Map<String, dynamic>,
            ),
      stats: UserStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'subscription_type': instance.subscriptionType,
      'photo_url': instance.photoUrl,
      'relationship': instance.relationship,
      'stats': instance.stats,
    };

UserCreateModel _$UserCreateModelFromJson(Map<String, dynamic> json) =>
    UserCreateModel(
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserCreateModelToJson(UserCreateModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
    };

UserUpdateModel _$UserUpdateModelFromJson(Map<String, dynamic> json) =>
    UserUpdateModel(
      username: json['username'] as String?,
      name: json['name'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$UserUpdateModelToJson(UserUpdateModel instance) =>
    <String, dynamic>{
      'username': ?instance.username,
      'name': ?instance.name,
      'password': ?instance.password,
    };
