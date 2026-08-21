// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: json['idCategory'] as String,
      name: json['strCategory'] as String,
      thumbnail: json['strCategoryThumb'] as String?,
      description: json['strCategoryDescription'] as String?,
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'idCategory': instance.id,
      'strCategory': instance.name,
      'strCategoryThumb': instance.thumbnail,
      'strCategoryDescription': instance.description,
    };
