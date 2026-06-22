class CareerMatch {
  final String id;
  final String title;
  final String? summary;
  final String? matchReason;
  final int? fitScore;
  final List<SkillTag> requiredSkills;
  final String? outlook;
  final List<RoadmapStep> roadmap;
  final bool isSaved;
  final String? source;

  const CareerMatch({
    required this.id,
    required this.title,
    this.summary,
    this.matchReason,
    this.fitScore,
    this.requiredSkills = const [],
    this.outlook,
    this.roadmap = const [],
    this.isSaved = false,
    this.source,
  });

  factory CareerMatch.fromJson(Map<String, dynamic> json) => CareerMatch(
    id: json['id'] as String,
    title: json['title'] as String,
    summary: json['summary'] as String?,
    matchReason: json['match_reason'] as String?,
    fitScore: json['fit_score'] as int?,
    requiredSkills: (json['required_skills'] as List<dynamic>? ?? [])
        .map((e) => SkillTag.fromJson(e as Map<String, dynamic>))
        .toList(),
    outlook: json['outlook'] as String?,
    roadmap: (json['roadmap'] as List<dynamic>? ?? [])
        .map((e) => RoadmapStep.fromJson(e as Map<String, dynamic>))
        .toList(),
    isSaved: json['is_saved'] as bool? ?? false,
    source: json['source'] as String?,
  );
}

class SkillTag {
  final String name;
  final String level;

  const SkillTag({required this.name, required this.level});

  factory SkillTag.fromJson(Map<String, dynamic> json) => SkillTag(
    name: json['name'] as String,
    level: json['level'] as String? ?? 'beginner',
  );
}

class RoadmapStep {
  final int order;
  final String title;
  final String detail;

  const RoadmapStep({
    required this.order,
    required this.title,
    required this.detail,
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) => RoadmapStep(
    order: json['order'] as int,
    title: json['title'] as String,
    detail: json['detail'] as String,
  );
}
