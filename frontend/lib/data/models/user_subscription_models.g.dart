// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSubscriptionModel _$UserSubscriptionModelFromJson(
  Map<String, dynamic> json,
) => UserSubscriptionModel(
  subscriberId: (json['subscriber_id'] as num).toInt(),
  subscribedUserId: (json['subscribed_user_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserSubscriptionModelToJson(
  UserSubscriptionModel instance,
) => <String, dynamic>{
  'subscriber_id': instance.subscriberId,
  'subscribed_user_id': instance.subscribedUserId,
  'created_at': instance.createdAt.toIso8601String(),
};

UserSubscriptionCreateModel _$UserSubscriptionCreateModelFromJson(
  Map<String, dynamic> json,
) => UserSubscriptionCreateModel(
  subscribedUserId: (json['subscribed_user_id'] as num).toInt(),
  subscriberId: (json['subscriber_id'] as num).toInt(),
);

Map<String, dynamic> _$UserSubscriptionCreateModelToJson(
  UserSubscriptionCreateModel instance,
) => <String, dynamic>{
  'subscribed_user_id': instance.subscribedUserId,
  'subscriber_id': instance.subscriberId,
};

UserConnectionModel _$UserConnectionModelFromJson(Map<String, dynamic> json) =>
    UserConnectionModel(
      user: UserCompactModel.fromJson(json['user'] as Map<String, dynamic>),
      isFollowedByMe: json['is_followed_by_me'] as bool? ?? false,
    );

Map<String, dynamic> _$UserConnectionModelToJson(
  UserConnectionModel instance,
) => <String, dynamic>{
  'user': instance.user,
  'is_followed_by_me': instance.isFollowedByMe,
};
