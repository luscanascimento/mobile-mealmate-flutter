import 'package:equatable/equatable.dart';

/// A single recipe ingredient paired with its measure (e.g. "Flour" / "200g").
class Ingredient extends Equatable {
  const Ingredient({required this.name, required this.measure});

  final String name;
  final String measure;

  /// Normalized key used for de-duplication in the shopping list
  /// (case-insensitive, trimmed).
  String get normalizedName => name.trim().toLowerCase();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'measure': measure,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: (json['name'] as String?) ?? '',
        measure: (json['measure'] as String?) ?? '',
      );

  @override
  List<Object?> get props => <Object?>[name, measure];
}
