// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_type_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionTypeModel _$SubscriptionTypeModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionTypeModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$SubscriptionTypeModelToJson(
  SubscriptionTypeModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
};

SubscriptionTypeCreateModel _$SubscriptionTypeCreateModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionTypeCreateModel(
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$SubscriptionTypeCreateModelToJson(
  SubscriptionTypeCreateModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
};
