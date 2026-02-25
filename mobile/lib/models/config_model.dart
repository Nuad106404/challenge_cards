import 'dart:convert';

class SupportedLanguage {
  final String code;
  final String label;

  const SupportedLanguage({required this.code, required this.label});

  factory SupportedLanguage.fromJson(Map<String, dynamic> json) =>
      SupportedLanguage(
        code: json['code'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'code': code, 'label': label};
}

class ConfigModel {
  final String id;
  final bool adsEnabled;
  final String admobAppId;
  final String admobBannerId;
  final String admobInterstitialId;
  final int contentVersion;
  final String minAppVersion;
  final String updatedAt;
  final List<SupportedLanguage> supportedLanguages;
  final int adRotationDuration;
  final String apiBaseUrl;

  const ConfigModel({
    required this.id,
    required this.adsEnabled,
    required this.admobAppId,
    required this.admobBannerId,
    required this.admobInterstitialId,
    required this.contentVersion,
    required this.minAppVersion,
    required this.updatedAt,
    required this.supportedLanguages,
    this.adRotationDuration = 5,
    this.apiBaseUrl = '',
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    final langs = (json['supportedLanguages'] as List<dynamic>? ?? [])
        .map((e) => SupportedLanguage.fromJson(e as Map<String, dynamic>))
        .toList();
    return ConfigModel(
      id: json['_id'] as String? ?? '',
      adsEnabled: json['adsEnabled'] as bool? ?? false,
      admobAppId: json['admobAppId'] as String? ?? '',
      admobBannerId: json['admobBannerId'] as String? ?? '',
      admobInterstitialId: json['admobInterstitialId'] as String? ?? '',
      contentVersion: json['contentVersion'] as int? ?? 0,
      minAppVersion: json['minAppVersion'] as String? ?? '1.0.0',
      updatedAt: json['updatedAt'] as String? ?? '',
      supportedLanguages: langs.isNotEmpty
          ? langs
          : [SupportedLanguage(code: 'en', label: 'English')],
      adRotationDuration: json['adRotationDuration'] as int? ?? 5,
      apiBaseUrl: json['apiBaseUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'adsEnabled': adsEnabled,
        'admobAppId': admobAppId,
        'admobBannerId': admobBannerId,
        'admobInterstitialId': admobInterstitialId,
        'contentVersion': contentVersion,
        'minAppVersion': minAppVersion,
        'updatedAt': updatedAt,
        'supportedLanguages': supportedLanguages.map((l) => l.toJson()).toList(),
        'adRotationDuration': adRotationDuration,
        'apiBaseUrl': apiBaseUrl,
      };

  String toJsonString() => jsonEncode(toJson());

  factory ConfigModel.fromJsonString(String source) =>
      ConfigModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  ConfigModel copyWith({
    String? id,
    bool? adsEnabled,
    String? admobAppId,
    String? admobBannerId,
    String? admobInterstitialId,
    int? contentVersion,
    String? minAppVersion,
    String? updatedAt,
    List<SupportedLanguage>? supportedLanguages,
    int? adRotationDuration,
    String? apiBaseUrl,
  }) {
    return ConfigModel(
      id: id ?? this.id,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      admobAppId: admobAppId ?? this.admobAppId,
      admobBannerId: admobBannerId ?? this.admobBannerId,
      admobInterstitialId: admobInterstitialId ?? this.admobInterstitialId,
      contentVersion: contentVersion ?? this.contentVersion,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      adRotationDuration: adRotationDuration ?? this.adRotationDuration,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
    );
  }
}
