class UserGoal {
  final String id;
  final int durationMonths;
  final DateTime targetDate;
  final bool isActive;

  const UserGoal({
    required this.id,
    required this.durationMonths,
    required this.targetDate,
    this.isActive = true,
  });

  factory UserGoal.fromJson(Map<String, dynamic> json) => UserGoal(
        id: json['id'] as String,
        durationMonths: json['duration_months'] as int,
        targetDate: DateTime.parse(json['target_date'] as String),
        isActive: json['is_active'] as bool? ?? true,
      );

  int get daysLeft => targetDate.difference(DateTime.now()).inDays.clamp(0, 9999);
  int get totalDays => durationMonths * 30;
  int get daysElapsed => (totalDays - daysLeft).clamp(0, totalDays);
  double get timeProgress => totalDays == 0 ? 0 : daysElapsed / totalDays;

  String get label {
    if (durationMonths == 3) return '3 Months';
    if (durationMonths == 6) return '6 Months';
    if (durationMonths == 12) return '1 Year';
    return '$durationMonths Months';
  }
}