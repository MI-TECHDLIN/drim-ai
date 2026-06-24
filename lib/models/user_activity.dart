class UserActivity {
  final String id;
  final String activityType;
  final DateTime activityDate;
  final int intensity;

  const UserActivity({
    required this.id,
    required this.activityType,
    required this.activityDate,
    this.intensity = 1,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) => UserActivity(
        id: json['id'] as String,
        activityType: json['activity_type'] as String,
        activityDate: DateTime.parse(json['activity_date'] as String),
        intensity: json['intensity'] as int? ?? 1,
      );
}