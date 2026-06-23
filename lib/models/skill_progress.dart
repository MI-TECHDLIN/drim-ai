class SkillProgress {
  final String id;
  final String? userId;
  final String? matchId;
  final String skillName;
  String status; // mutable for local cycling

  SkillProgress({
    required this.id,
    this.userId,
    this.matchId,
    required this.skillName,
    required this.status,
  });

  factory SkillProgress.fromJson(Map<String, dynamic> json) => SkillProgress(
    id: json['id'] as String,
    userId: json['user_id'] as String?,
    matchId: json['match_id'] as String?,
    skillName: json['skill_name'] as String,
    status: json['status'] as String? ?? 'not_started',
  );

  /// Local (non-DB) skill — used for fallback matches
  factory SkillProgress.local(String skillName) => SkillProgress(
    id: 'local_${skillName.hashCode}',
    skillName: skillName,
    status: 'not_started',
  );

  String get nextStatus {
    switch (status) {
      case 'not_started':
        return 'learning';
      case 'learning':
        return 'done';
      default:
        return 'not_started';
    }
  }
}
