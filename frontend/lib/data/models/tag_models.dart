import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag_models.g.dart';

// ==========================================
// TAG RESPONSE MODEL
// Matches TagResponse in FastAPI
// ==========================================
@JsonSerializable()
class TagModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'created_by_user_id')
  final int createdByUserId;

  const TagModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdByUserId,
  });

  // Factory constructor for generating a new instance from a JSON map
  factory TagModel.fromJson(Map<String, dynamic> json) => _$TagModelFromJson(json);

  // Method for converting the instance to a JSON map
  Map<String, dynamic> toJson() => _$TagModelToJson(this);

  @override
  List<Object?> get props => [id, name, description, createdByUserId];
}

// ==========================================
// TAG CREATE MODEL
// Matches TagCreate in FastAPI
// ==========================================
@JsonSerializable()
class TagCreateModel extends Equatable {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'created_by_user_id')
  final int createdByUserId;

  const TagCreateModel({
    required this.name,
    this.description,
    required this.createdByUserId,
  });

  factory TagCreateModel.fromJson(Map<String, dynamic> json) => _$TagCreateModelFromJson(json);
  Map<String, dynamic> toJson() => _$TagCreateModelToJson(this);

  @override
  List<Object?> get props => [name, description, createdByUserId];
}

// ==========================================
// TAG UPDATE MODEL
// Matches TagUpdate in FastAPI (PATCH request)
// ==========================================
// includeIfNull: false ensures we don't send null fields to the backend
@JsonSerializable(includeIfNull: false)
class TagUpdateModel extends Equatable {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'description')
  final String? description;

  const TagUpdateModel({
    this.name,
    this.description,
  });

  factory TagUpdateModel.fromJson(Map<String, dynamic> json) => _$TagUpdateModelFromJson(json);
  Map<String, dynamic> toJson() => _$TagUpdateModelToJson(this);

  @override
  List<Object?> get props => [name, description];
}