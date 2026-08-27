// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      area: json['area'] as String?,
      instructions: json['instructions'] as String?,
      thumbnail: json['thumbnail'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Ingredient>[],
    );

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'area': instance.area,
      'instructions': instance.instructions,
      'thumbnail': instance.thumbnail,
      'youtubeUrl': instance.youtubeUrl,
      'sourceUrl': instance.sourceUrl,
      'tags': instance.tags,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
    };
