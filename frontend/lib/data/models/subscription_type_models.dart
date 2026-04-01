import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_type_models.g.dart';

// ==========================================
// SUBSCRIPTION TYPE RESPONSE MODEL
// Matches SubscriptionTypeResponse in FastAPI
// ==========================================
@JsonSerializable()
class SubscriptionTypeModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  const SubscriptionTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  // Factory constructor for generating a new instance from a JSON map
  factory SubscriptionTypeModel.fromJson(Map<String, dynamic> json) => _$SubscriptionTypeModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$SubscriptionTypeModelToJson(this);

  @override
  List<Object?> get props => [id, name, description];
}

// ==========================================
// SUBSCRIPTION TYPE CREATE MODEL
// Matches SubscriptionTypeCreate in FastAPI
// ==========================================
@JsonSerializable()
class SubscriptionTypeCreateModel extends Equatable {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  const SubscriptionTypeCreateModel({
    required this.name,
    this.description,
  });

  factory SubscriptionTypeCreateModel.fromJson(Map<String, dynamic> json) => _$SubscriptionTypeCreateModelFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionTypeCreateModelToJson(this);

  @override
  List<Object?> get props => [name, description];
}