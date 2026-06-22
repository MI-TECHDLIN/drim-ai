class Profile {
  final String id;
  final String? displayName;
  final String? ageBand;
  final String? educationStage;
  final DateTime? createdAt;

  const Profile({
    required this.id,
    this.displayName,
    this.ageBand,
    this.educationStage,
    this.createdAt,
  });

  bool get isComplete =>
      displayName != null &&
      displayName!.trim().isNotEmpty &&
      ageBand != null &&
      educationStage != null;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    displayName: json['display_name'] as String?,
    ageBand: json['age_band'] as String?,
    educationStage: json['education_stage'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );
}
