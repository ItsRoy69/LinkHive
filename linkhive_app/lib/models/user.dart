// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final Map<String, dynamic>? settings;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.settings,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      settings: json['settings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'settings': settings,
    };
  }
}