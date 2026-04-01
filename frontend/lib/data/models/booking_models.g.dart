// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  giftId: (json['gift_id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'gift_id': instance.giftId,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
    };

BookingCreateModel _$BookingCreateModelFromJson(Map<String, dynamic> json) =>
    BookingCreateModel(
      giftId: (json['gift_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
    );

Map<String, dynamic> _$BookingCreateModelToJson(BookingCreateModel instance) =>
    <String, dynamic>{'gift_id': instance.giftId, 'user_id': instance.userId};
