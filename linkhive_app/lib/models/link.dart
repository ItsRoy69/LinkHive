// lib/models/link.dart
class Link {
  final int id;
  final int userId;
  final int? categoryId;
  final String url;
  final String? title;
  final String type;
  final String status;
  final Map<String, dynamic>? metadata;
  final bool sharedFlag;
  final bool pinnedFlag;
  final int orderIndex;
  final bool isDead;
  final DateTime createdAt;
  final DateTime updatedAt;

  Link({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.url,
    this.title,
    required this.type,
    required this.status,
    this.metadata,
    required this.sharedFlag,
    required this.pinnedFlag,
    required this.orderIndex,
    required this.isDead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      url: json['url'],
      title: json['title'],
      type: json['type'],
      status: json['status'],
      metadata: json['metadata'],
      sharedFlag: json['shared_flag'] ?? false,
      pinnedFlag: json['pinned_flag'] ?? false,
      orderIndex: json['order_index'] ?? 0,
      isDead: json['is_dead'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'url': url,
      'title': title,
      'type': type,
      'status': status,
      'metadata': metadata,
      'shared_flag': sharedFlag,
      'pinned_flag': pinnedFlag,
      'order_index': orderIndex,
      'is_dead': isDead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}