class Goal {
  final int? id;
  final int userId;
  final String goalType;
  final String description;
  final int targetCount;
  final int progress;
  final DateTime startDate;
  final DateTime endDate;
  final bool completed;

  Goal({
    this.id,
    required this.userId,
    required this.goalType,
    required this.description,
    required this.targetCount,
    this.progress = 0,
    required this.startDate,
    required this.endDate,
    this.completed = false,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['user_id'],
      goalType: json['goal_type'],
      description: json['description'],
      targetCount: json['target_count'],
      progress: json['progress'] ?? 0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': goalType,
      'description': description,
      'target_count': targetCount,
      'progress': progress,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'completed': completed,
    };
  }

  double get progressPercentage {
    if (targetCount == 0) return 0;
    return (progress / targetCount * 100).clamp(0, 100);
  }
}