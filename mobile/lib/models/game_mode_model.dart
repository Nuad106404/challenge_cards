import 'dart:convert';

class GameModeModel {
  final String id;
  final String slug;
  final Map<String, String> name;
  final Map<String, String> description;
  final bool isActive;
  final int sortOrder;

  const GameModeModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.isActive,
    required this.sortOrder,
  });

  /// Returns the name for [locale], falling back to 'en', then the first available value.
  String localizedName(String locale) =>
      name[locale] ?? name['en'] ?? name.values.firstOrNull ?? '';

  /// Returns the description for [locale], falling back to 'en', then the first available value.
  String localizedDescription(String locale) =>
      description[locale] ?? description['en'] ?? description.values.firstOrNull ?? '';

  factory GameModeModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> toStringMap(Map<String, dynamic> m) =>
        Map<String, String>.fromEntries(
          m.entries.map((e) => MapEntry(e.key, e.value?.toString() ?? '')),
        );
    return GameModeModel(
      id: json['_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: toStringMap(json['name'] as Map<String, dynamic>? ?? {}),
      description: toStringMap(json['description'] as Map<String, dynamic>? ?? {}),
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'slug': slug,
        'name': name,
        'description': description,
        'isActive': isActive,
        'sortOrder': sortOrder,
      };

  String toJsonString() => jsonEncode(toJson());

  factory GameModeModel.fromJsonString(String source) =>
      GameModeModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static List<GameModeModel> listFromJson(List<dynamic> list) =>
      list.map((e) => GameModeModel.fromJson(e as Map<String, dynamic>)).toList();

  static String listToJsonString(List<GameModeModel> modes) =>
      jsonEncode(modes.map((m) => m.toJson()).toList());

  static List<GameModeModel> listFromJsonString(String source) =>
      listFromJson(jsonDecode(source) as List<dynamic>);
}
