import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/user_models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_subscription_models.g.dart';

// ==========================================
// USER SUBSCRIPTION RESPONSE MODEL
// Matches UserSubscriptionResponse in FastAPI
// ==========================================
@JsonSerializable()
class UserSubscriptionModel extends Equatable {
  @JsonKey(name: 'subscriber_id')
  final int subscriberId;

  @JsonKey(name: 'subscribed_user_id')
  final int subscribedUserId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const UserSubscriptionModel({
    required this.subscriberId,
    required this.subscribedUserId,
    required this.createdAt,
  });

  // Factory constructor for generating a new instance from a JSON map
  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) => _$UserSubscriptionModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$UserSubscriptionModelToJson(this);

  @override
  List<Object?> get props => [subscriberId, subscribedUserId, createdAt];
}

// ==========================================
// USER SUBSCRIPTION CREATE MODEL
// Matches UserSubscriptionCreate in FastAPI
// ==========================================
@JsonSerializable()
class UserSubscriptionCreateModel extends Equatable {
  @JsonKey(name: 'subscribed_user_id')
  final int subscribedUserId;

  @JsonKey(name: 'subscriber_id')
  final int subscriberId;

  const UserSubscriptionCreateModel({
    required this.subscribedUserId,
    required this.subscriberId,
  });

  factory UserSubscriptionCreateModel.fromJson(Map<String, dynamic> json) => _$UserSubscriptionCreateModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserSubscriptionCreateModelToJson(this);

  @override
  List<Object?> get props => [subscribedUserId, subscriberId];
}

// ==========================================
// USER CONNECTION MODEL
// Matches UserConnectionModel in FastAPI
// ==========================================
@JsonSerializable()
class UserConnectionModel extends Equatable {
  @JsonKey(name: 'user')
  final UserCompactModel user;

  @JsonKey(name: 'is_followed_by_me', defaultValue: false)
  final bool isFollowedByMe;

  const UserConnectionModel({
    required this.user,
    required this.isFollowedByMe,
  });

  factory UserConnectionModel.fromJson(Map<String, dynamic> json) => _$UserConnectionModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserConnectionModelToJson(this);

  @override
  List<Object?> get props => [user, isFollowedByMe];
}