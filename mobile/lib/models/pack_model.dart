import 'dart:convert';

class LocalizedText {
  final Map<String, String> values;

  const LocalizedText(this.values);

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      Map<String, String>.fromEntries(
        json.entries.map((e) => MapEntry(e.key, e.value?.toString() ?? '')),
      ),
    );
  }

  /// Returns the text for [locale], falling back to 'en', then the first available value.
  String localized(String locale) =>
      values[locale] ?? values['en'] ?? values.values.firstOrNull ?? '';

  Map<String, dynamic> toJson() => values;
}

class PackModel {
  final String id;
  final String slug;
  final LocalizedText title;
  final LocalizedText description;
  final String mode; // 'friends' | 'couple'
  final String ageRating; // 'all' | '18+'
  final bool isActive;
  final String coverImageUrl;
  final int sortOrder;

  const PackModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.mode,
    required this.ageRating,
    required this.isActive,
    required this.coverImageUrl,
    required this.sortOrder,
  });

  factory PackModel.fromJson(Map<String, dynamic> json) {
    return PackModel(
      id: json['_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>? ?? {}),
      description: LocalizedText.fromJson(json['description'] as Map<String, dynamic>? ?? {}),
      mode: json['mode'] as String? ?? 'friends',
      ageRating: json['ageRating'] as String? ?? 'all',
      isActive: json['isActive'] as bool? ?? true,
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'slug': slug,
        'title': title.toJson(),
        'description': description.toJson(),
        'mode': mode,
        'ageRating': ageRating,
        'isActive': isActive,
        'coverImageUrl': coverImageUrl,
        'sortOrder': sortOrder,
      };

  String toJsonString() => jsonEncode(toJson());

  factory PackModel.fromJsonString(String source) =>
      PackModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static List<PackModel> listFromJson(List<dynamic> list) =>
      list.map((e) => PackModel.fromJson(e as Map<String, dynamic>)).toList();

  static String listToJsonString(List<PackModel> packs) =>
      jsonEncode(packs.map((p) => p.toJson()).toList());

  static List<PackModel> listFromJsonString(String source) =>
      listFromJson(jsonDecode(source) as List<dynamic>);
}
