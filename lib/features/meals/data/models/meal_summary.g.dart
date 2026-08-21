// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealSummaryImpl _$$MealSummaryImplFromJson(Map<String, dynamic> json) =>
    _$MealSummaryImpl(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String?,
    );

Map<String, dynamic> _$$MealSummaryImplToJson(_$MealSummaryImpl instance) =>
    <String, dynamic>{
      'idMeal': instance.id,
      'strMeal': instance.name,
      'strMealThumb': instance.thumbnail,
    };
