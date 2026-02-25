import 'dart:convert';
import 'pack_model.dart';

class ImageMeta {
  final int width;
  final int height;
  final int size;
  final String mime;

  const ImageMeta({
    required this.width,
    required this.height,
    required this.size,
    required this.mime,
  });

  factory ImageMeta.fromJson(Map<String, dynamic> json) {
    return ImageMeta(
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      mime: json['mime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'size': size,
    'mime': mime,
  };
}

class CardModel {
  final String id;
  final String packId;
  final String type; // 'question' | 'dare' | 'vote' | 'punishment' | 'bonus' | 'minigame'
  final LocalizedText text;
  final List<String> tags;
  final String difficulty; // 'easy' | 'medium' | 'hard'
  final String ageRating; // 'all' | '18+'
  final int diceCount; // 0 = no dice, 1-6 = number of dice to roll
  final bool isActive;
  final String status; // 'draft' | 'review' | 'published'
  final String contentSource; // 'manual' | 'image'
  final String? imageUrl;
  final ImageMeta? imageMeta;

  const CardModel({
    required this.id,
    required this.packId,
    required this.type,
    required this.text,
    required this.tags,
    required this.difficulty,
    required this.ageRating,
    this.diceCount = 0,
    required this.isActive,
    required this.status,
    this.contentSource = 'manual',
    this.imageUrl,
    this.imageMeta,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final packIdRaw = json['packId'];
    final packId = packIdRaw is Map ? (packIdRaw['_id'] as String? ?? '') : (packIdRaw as String? ?? '');

    return CardModel(
      id: json['_id'] as String? ?? '',
      packId: packId,
      type: json['type'] as String? ?? 'question',
      text: LocalizedText.fromJson(json['text'] as Map<String, dynamic>? ?? {}),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      difficulty: json['difficulty'] as String? ?? 'medium',
      ageRating: json['ageRating'] as String? ?? 'all',
      diceCount: (json['diceCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      status: json['status'] as String? ?? 'published',
      contentSource: json['contentSource'] as String? ?? 'manual',
      imageUrl: json['imageUrl'] as String?,
      imageMeta: json['imageMeta'] != null 
        ? ImageMeta.fromJson(json['imageMeta'] as Map<String, dynamic>)
        : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'packId': packId,
        'type': type,
        'text': text.toJson(),
        'tags': tags,
        'difficulty': difficulty,
        'ageRating': ageRating,
        'diceCount': diceCount,
        'isActive': isActive,
        'status': status,
        'contentSource': contentSource,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (imageMeta != null) 'imageMeta': imageMeta!.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory CardModel.fromJsonString(String source) =>
      CardModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static List<CardModel> listFromJson(List<dynamic> list) =>
      list.map((e) => CardModel.fromJson(e as Map<String, dynamic>)).toList();

  static String listToJsonString(List<CardModel> cards) =>
      jsonEncode(cards.map((c) => c.toJson()).toList());

  static List<CardModel> listFromJsonString(String source) =>
      listFromJson(jsonDecode(source) as List<dynamic>);
}
