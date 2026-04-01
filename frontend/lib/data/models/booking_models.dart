import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'booking_models.g.dart';

// ==========================================
// BOOKING RESPONSE MODEL
// Matches BookingResponse in FastAPI
// ==========================================
@JsonSerializable()
class BookingModel extends Equatable {
  @JsonKey(name: 'gift_id')
  final int giftId;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const BookingModel({
    required this.giftId,
    required this.userId,
    required this.createdAt,
  });

  // Factory constructor for generating a new instance from a JSON map
  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  @override
  List<Object?> get props => [giftId, userId, createdAt];
}

// ==========================================
// BOOKING CREATE MODEL
// Matches BookingCreate in FastAPI
// ==========================================
@JsonSerializable()
class BookingCreateModel extends Equatable {
  @JsonKey(name: 'gift_id')
  final int giftId;

  @JsonKey(name: 'user_id')
  final int userId;

  const BookingCreateModel({
    required this.giftId,
    required this.userId,
  });

  factory BookingCreateModel.fromJson(Map<String, dynamic> json) => _$BookingCreateModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$BookingCreateModelToJson(this);

  @override
  List<Object?> get props => [giftId, userId];
}