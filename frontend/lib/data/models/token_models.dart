import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token_models.g.dart';

// ==========================================
// TOKEN RESPONSE MODEL
// Matches Token in FastAPI
// ==========================================
@JsonSerializable()
class TokenModel extends Equatable {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  const TokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
  });

  // Factory constructor for generating a new instance from a JSON map
  factory TokenModel.fromJson(Map<String, dynamic> json) => _$TokenModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$TokenModelToJson(this);

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType];
}

// ==========================================
// TOKEN PAYLOAD MODEL
// Matches TokenPayload in FastAPI
// Useful if we decide to decode JWT locally in Flutter
// ==========================================
@JsonSerializable()
class TokenPayloadModel extends Equatable {
  @JsonKey(name: 'sub')
  final String? sub;

  @JsonKey(name: 'version')
  final int? version;

  const TokenPayloadModel({
    this.sub,
    this.version,
  });

  factory TokenPayloadModel.fromJson(Map<String, dynamic> json) => _$TokenPayloadModelFromJson(json);
  Map<String, dynamic> toJson() => _$TokenPayloadModelToJson(this);

  @override
  List<Object?> get props => [sub, version];
}

// ==========================================
// TOKEN REFRESH MODEL
// Matches TokenRefresh in FastAPI
// Used in AuthInterceptor for the /auth/refresh request
// ==========================================
@JsonSerializable()
class TokenRefreshModel extends Equatable {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const TokenRefreshModel({
    required this.refreshToken,
  });

  factory TokenRefreshModel.fromJson(Map<String, dynamic> json) => _$TokenRefreshModelFromJson(json);
  Map<String, dynamic> toJson() => _$TokenRefreshModelToJson(this);

  @override
  List<Object?> get props => [refreshToken];
}