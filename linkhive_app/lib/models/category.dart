class Category {
  final int? id;
  final int userId;
  final String name;
  final int orderIndex;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    this.id,
    required this.userId,
    required this.name,
    this.orderIndex = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      orderIndex: json['order_index'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'order_index': orderIndex,
    };
  }

  Category copyWith({
    int? id,
    int? userId,
    String? name,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}