class Reminder {
  final int? id;
  final int linkId;
  final int userId;
  final DateTime reminderTime;
  final bool sent;
  final String? note;

  Reminder({
    this.id,
    required this.linkId,
    required this.userId,
    required this.reminderTime,
    this.sent = false,
    this.note,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      linkId: json['link_id'],
      userId: json['user_id'],
      reminderTime: DateTime.parse(json['reminder_time']),
      sent: json['sent'] ?? false,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'link_id': linkId,
      'user_id': userId,
      'reminder_time': reminderTime.toIso8601String(),
      'sent': sent,
      'note': note,
    };
  }
}