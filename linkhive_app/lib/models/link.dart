class Link {
  final int? id;
  final int userId;
  final int? categoryId;
  final String url;
  final String? title;
  final LinkType type;
  final LinkStatus status;
  final Map<String, dynamic>? metadata;
  final bool sharedFlag;
  final bool pinnedFlag;
  final int orderIndex;
  final bool isDead;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? tags;

  Link({
    this.id,
    required this.userId,
    this.categoryId,
    required this.url,
    this.title,
    this.type = LinkType.other,
    this.status = LinkStatus.none,
    this.metadata,
    this.sharedFlag = false,
    this.pinnedFlag = false,
    this.orderIndex = 0,
    this.isDead = false,
    this.createdAt,
    this.updatedAt,
    this.tags,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      url: json['url'],
      title: json['title'],
      type: LinkType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => LinkType.other,
      ),
      status: LinkStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => LinkStatus.none,
      ),
      metadata: json['metadata'],
      sharedFlag: json['shared_flag'] ?? false,
      pinnedFlag: json['pinned_flag'] ?? false,
      orderIndex: json['order_index'] ?? 0,
      isDead: json['is_dead'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'].map((tag) => tag['name'])) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'url': url,
      'title': title,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'metadata': metadata,
      'shared_flag': sharedFlag,
      'pinned_flag': pinnedFlag,
      'order_index': orderIndex,
      'is_dead': isDead,
    };
  }

  Link copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? url,
    String? title,
    LinkType? type,
    LinkStatus? status,
    Map<String, dynamic>? metadata,
    bool? sharedFlag,
    bool? pinnedFlag,
    int? orderIndex,
    bool? isDead,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Link(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      url: url ?? this.url,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      sharedFlag: sharedFlag ?? this.sharedFlag,
      pinnedFlag: pinnedFlag ?? this.pinnedFlag,
      orderIndex: orderIndex ?? this.orderIndex,
      isDead: isDead ?? this.isDead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}

enum LinkType {
  job,
  reel,
  article,
  video,
  other,
}

enum LinkStatus {
  applied,
  notApplied,
  read,
  unread,
  none,
}