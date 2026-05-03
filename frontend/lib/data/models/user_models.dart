import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/lookup_models.dart';

part 'user_models.g.dart';

// ==========================================
// 1. NESTED COMPONENT MODELS
// ==========================================

@JsonSerializable()
class UserStatsModel extends Equatable {
  @JsonKey(name: 'followers_count', defaultValue: 0)
  final int followersCount;

  @JsonKey(name: 'following_count', defaultValue: 0)
  final int followingCount;

  const UserStatsModel({
    this.followersCount = 0,
    this.followingCount = 0,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) => _$UserStatsModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsModelToJson(this);

  @override
  List<Object?> get props => [followersCount, followingCount];
}

@JsonSerializable()
class UserRelationshipModel extends Equatable {
  @JsonKey(name: 'is_following', defaultValue: false)
  final bool isFollowing;

  @JsonKey(name: 'is_follower', defaultValue: false)
  final bool isFollower;

  const UserRelationshipModel({
    this.isFollowing = false,
    this.isFollower = false,
  });

  factory UserRelationshipModel.fromJson(Map<String, dynamic> json) => _$UserRelationshipModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserRelationshipModelToJson(this);

  @override
  List<Object?> get props => [isFollowing, isFollower];
}

// ==========================================
// 2. RESPONSE MODELS (Using Inheritance)
// ==========================================

// Matches UserBase in FastAPI
@JsonSerializable()
class UserBaseModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'subscription_type')
  final SubscriptionPlanModel subscriptionType;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  const UserBaseModel({
    required this.id,
    required this.username,
    required this.name,
    required this.subscriptionType,
    this.photoUrl,
  });

  factory UserBaseModel.fromJson(Map<String, dynamic> json) => _$UserBaseModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserBaseModelToJson(this);

  @override
  List<Object?> get props => [id, username, name, subscriptionType, photoUrl];
}

// Matches PrivateUser in FastAPI (Current logged-in user)
@JsonSerializable()
class PrivateUserModel extends UserBaseModel {
  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const PrivateUserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.subscriptionType,
    super.photoUrl,
    required this.email,
    required this.createdAt,
  });

  factory PrivateUserModel.fromJson(Map<String, dynamic> json) => _$PrivateUserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrivateUserModelToJson(this);

  @override
  List<Object?> get props => [...super.props, email, createdAt];
}

// Matches SocialUser in FastAPI (Users in lists, search, feeds)
@JsonSerializable()
class SocialUserModel extends UserBaseModel {
  @JsonKey(name: 'relationship')
  final UserRelationshipModel? relationship;

  const SocialUserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.subscriptionType,
    super.photoUrl,
    this.relationship,
  });

  factory SocialUserModel.fromJson(Map<String, dynamic> json) => _$SocialUserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SocialUserModelToJson(this);

  @override
  List<Object?> get props => [...super.props, relationship];
}

// Matches UserProfile in FastAPI (Full profile view)
@JsonSerializable()
class UserProfileModel extends SocialUserModel {
  @JsonKey(name: 'stats')
  final UserStatsModel stats;

  const UserProfileModel({
    required super.id,
    required super.username,
    required super.name,
    required super.subscriptionType,
    super.photoUrl,
    super.relationship,
    required this.stats,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  @override
  List<Object?> get props => [...super.props, stats];
}

// ==========================================
// 3. REQUEST MODELS
// ==========================================

// Matches UserCreate in FastAPI (Registration)
@JsonSerializable()
class UserCreateModel extends Equatable {
  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'password')
  final String password;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  const UserCreateModel({
    required this.username,
    required this.name,
    required this.email,
    required this.password,
    this.photoUrl,
  });

  factory UserCreateModel.fromJson(Map<String, dynamic> json) => _$UserCreateModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateModelToJson(this);

  @override
  List<Object?> get props => [username, name, email, password, photoUrl];
}

// Matches UserUpdate in FastAPI (PATCH request)
@JsonSerializable(includeIfNull: false)
class UserUpdateModel extends Equatable {
  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'password')
  final String? password;

  const UserUpdateModel({
    this.username,
    this.name,
    this.photoUrl,
    this.password,
  });

  factory UserUpdateModel.fromJson(Map<String, dynamic> json) => _$UserUpdateModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateModelToJson(this);

  @override
  List<Object?> get props => [username, name, photoUrl, password];
}