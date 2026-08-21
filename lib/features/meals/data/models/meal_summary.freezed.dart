// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MealSummary _$MealSummaryFromJson(Map<String, dynamic> json) {
  return _MealSummary.fromJson(json);
}

/// @nodoc
mixin _$MealSummary {
  @JsonKey(name: 'idMeal')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'strMeal')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'strMealThumb')
  String? get thumbnail => throw _privateConstructorUsedError;

  /// Serializes this MealSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealSummaryCopyWith<MealSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealSummaryCopyWith<$Res> {
  factory $MealSummaryCopyWith(
          MealSummary value, $Res Function(MealSummary) then) =
      _$MealSummaryCopyWithImpl<$Res, MealSummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'idMeal') String id,
      @JsonKey(name: 'strMeal') String name,
      @JsonKey(name: 'strMealThumb') String? thumbnail});
}

/// @nodoc
class _$MealSummaryCopyWithImpl<$Res, $Val extends MealSummary>
    implements $MealSummaryCopyWith<$Res> {
  _$MealSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? thumbnail = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealSummaryImplCopyWith<$Res>
    implements $MealSummaryCopyWith<$Res> {
  factory _$$MealSummaryImplCopyWith(
          _$MealSummaryImpl value, $Res Function(_$MealSummaryImpl) then) =
      __$$MealSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'idMeal') String id,
      @JsonKey(name: 'strMeal') String name,
      @JsonKey(name: 'strMealThumb') String? thumbnail});
}

/// @nodoc
class __$$MealSummaryImplCopyWithImpl<$Res>
    extends _$MealSummaryCopyWithImpl<$Res, _$MealSummaryImpl>
    implements _$$MealSummaryImplCopyWith<$Res> {
  __$$MealSummaryImplCopyWithImpl(
      _$MealSummaryImpl _value, $Res Function(_$MealSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MealSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? thumbnail = freezed,
  }) {
    return _then(_$MealSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MealSummaryImpl implements _MealSummary {
  const _$MealSummaryImpl(
      {@JsonKey(name: 'idMeal') required this.id,
      @JsonKey(name: 'strMeal') required this.name,
      @JsonKey(name: 'strMealThumb') this.thumbnail});

  factory _$MealSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'idMeal')
  final String id;
  @override
  @JsonKey(name: 'strMeal')
  final String name;
  @override
  @JsonKey(name: 'strMealThumb')
  final String? thumbnail;

  @override
  String toString() {
    return 'MealSummary(id: $id, name: $name, thumbnail: $thumbnail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, thumbnail);

  /// Create a copy of MealSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealSummaryImplCopyWith<_$MealSummaryImpl> get copyWith =>
      __$$MealSummaryImplCopyWithImpl<_$MealSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealSummaryImplToJson(
      this,
    );
  }
}

abstract class _MealSummary implements MealSummary {
  const factory _MealSummary(
          {@JsonKey(name: 'idMeal') required final String id,
          @JsonKey(name: 'strMeal') required final String name,
          @JsonKey(name: 'strMealThumb') final String? thumbnail}) =
      _$MealSummaryImpl;

  factory _MealSummary.fromJson(Map<String, dynamic> json) =
      _$MealSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'idMeal')
  String get id;
  @override
  @JsonKey(name: 'strMeal')
  String get name;
  @override
  @JsonKey(name: 'strMealThumb')
  String? get thumbnail;

  /// Create a copy of MealSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealSummaryImplCopyWith<_$MealSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
