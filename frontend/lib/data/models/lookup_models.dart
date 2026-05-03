import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lookup_models.g.dart';

// ==========================================
// SUBSCRIPTION PLAN RESPONSE MODEL
// Matches SubscriptionPlan in FastAPI
// ==========================================
@JsonSerializable()
class SubscriptionPlanModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    this.description,
  });

  // Factory constructor for generating a new instance from a JSON map
  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$SubscriptionPlanModelToJson(this);

  @override
  List<Object?> get props => [id, name, description];
}