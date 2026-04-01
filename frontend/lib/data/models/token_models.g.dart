// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenModel _$TokenModelFromJson(Map<String, dynamic> json) => TokenModel(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  tokenType: json['token_type'] as String? ?? 'bearer',
);

Map<String, dynamic> _$TokenModelToJson(TokenModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
    };

TokenPayloadModel _$TokenPayloadModelFromJson(Map<String, dynamic> json) =>
    TokenPayloadModel(
      sub: json['sub'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TokenPayloadModelToJson(TokenPayloadModel instance) =>
    <String, dynamic>{'sub': instance.sub, 'version': instance.version};

TokenRefreshModel _$TokenRefreshModelFromJson(Map<String, dynamic> json) =>
    TokenRefreshModel(refreshToken: json['refresh_token'] as String);

Map<String, dynamic> _$TokenRefreshModelToJson(TokenRefreshModel instance) =>
    <String, dynamic>{'refresh_token': instance.refreshToken};
