// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagModel _$TagModelFromJson(Map<String, dynamic> json) => TagModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  createdByUserId: (json['created_by_user_id'] as num).toInt(),
);

Map<String, dynamic> _$TagModelToJson(TagModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'created_by_user_id': instance.createdByUserId,
};

TagCreateModel _$TagCreateModelFromJson(Map<String, dynamic> json) =>
    TagCreateModel(
      name: json['name'] as String,
      description: json['description'] as String?,
      createdByUserId: (json['created_by_user_id'] as num).toInt(),
    );

Map<String, dynamic> _$TagCreateModelToJson(TagCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'created_by_user_id': instance.createdByUserId,
    };

TagUpdateModel _$TagUpdateModelFromJson(Map<String, dynamic> json) =>
    TagUpdateModel(
      name: json['name'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TagUpdateModelToJson(TagUpdateModel instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'description': ?instance.description,
    };
