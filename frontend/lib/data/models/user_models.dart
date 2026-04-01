import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

// ==========================================
// USER RESPONSE MODEL
// Matches UserResponse in FastAPI
// ==========================================
@JsonSerializable()
class UserModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'subscription_type_id')
  final int subscriptionTypeId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.subscriptionTypeId,
    required this.createdAt,
  });

  // Factory constructor for generating a new instance from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    username,
    name,
    email,
    photoUrl,
    subscriptionTypeId,
    createdAt,
  ];
}

// ==========================================
// USER CREATE MODEL
// Matches UserCreate in FastAPI (Registration)
// ==========================================
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

// ==========================================
// USER UPDATE MODEL
// Matches UserUpdate in FastAPI (PATCH request)
// ==========================================
// includeIfNull: false ensures we don't send null fields to the backend
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