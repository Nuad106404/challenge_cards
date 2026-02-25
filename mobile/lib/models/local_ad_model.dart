class LocalAdModel {
  final String id;
  final String label;
  final String imageUrl;
  final String linkUrl;
  final bool isActive;
  final int order;

  const LocalAdModel({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.linkUrl,
    required this.isActive,
    required this.order,
  });

  factory LocalAdModel.fromJson(Map<String, dynamic> json) => LocalAdModel(
        id: json['_id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        linkUrl: json['linkUrl'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? false,
        order: json['order'] as int? ?? 0,
      );
}
