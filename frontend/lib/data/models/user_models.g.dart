// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  photoUrl: json['photo_url'] as String?,
  subscriptionTypeId: (json['subscription_type_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'email': instance.email,
  'photo_url': instance.photoUrl,
  'subscription_type_id': instance.subscriptionTypeId,
  'created_at': instance.createdAt.toIso8601String(),
};

UserCreateModel _$UserCreateModelFromJson(Map<String, dynamic> json) =>
    UserCreateModel(
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      photoUrl: json['photo_url'] as String?,
    );

Map<String, dynamic> _$UserCreateModelToJson(UserCreateModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'photo_url': instance.photoUrl,
    };

UserUpdateModel _$UserUpdateModelFromJson(Map<String, dynamic> json) =>
    UserUpdateModel(
      username: json['username'] as String?,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$UserUpdateModelToJson(UserUpdateModel instance) =>
    <String, dynamic>{
      'username': ?instance.username,
      'name': ?instance.name,
      'photo_url': ?instance.photoUrl,
      'password': ?instance.password,
    };
