class GapSkill {
  final String skill;
  final String level;

  const GapSkill({required this.skill, required this.level});

  factory GapSkill.fromJson(Map<String, dynamic> json) => GapSkill(
    skill: json['skill'] as String,
    level: json['level'] as String? ?? 'beginner',
  );

  Map<String, dynamic> toJson() => {'skill': skill, 'level': level};
}

class CompanyRoadmapStep {
  final int order;
  final String title;
  final String detail;
  final int taskCount;
  final int resourceCount;
  String status; // 'locked' | 'active' | 'done'

  CompanyRoadmapStep({
    required this.order,
    required this.title,
    required this.detail,
    required this.taskCount,
    required this.resourceCount,
    required this.status,
  });

  factory CompanyRoadmapStep.fromJson(Map<String, dynamic> json) =>
      CompanyRoadmapStep(
        order: json['order'] as int,
        title: json['title'] as String,
        detail: json['detail'] as String,
        taskCount: json['taskCount'] as int? ?? 8,
        resourceCount: json['resourceCount'] as int? ?? 3,
        status: json['status'] as String? ?? 'locked',
      );

  Map<String, dynamic> toJson() => {
    'order': order,
    'title': title,
    'detail': detail,
    'taskCount': taskCount,
    'resourceCount': resourceCount,
    'status': status,
  };
}

class DreamCompanyGoal {
  final String id;
  final String company;
  final String role;
  final String experienceLevel;
  final List<String> youHave;
  final List<GapSkill> youNeed;
  final String? realityCheck;
  final List<CompanyRoadmapStep> steps;
  final int currentStep;

  const DreamCompanyGoal({
    required this.id,
    required this.company,
    required this.role,
    required this.experienceLevel,
    this.youHave = const [],
    this.youNeed = const [],
    this.realityCheck,
    this.steps = const [],
    this.currentStep = 0,
  });

  factory DreamCompanyGoal.fromJson(Map<String, dynamic> json) =>
      DreamCompanyGoal(
        id: json['id'] as String,
        company: json['company'] as String,
        role: json['role'] as String,
        experienceLevel: json['experience_level'] as String,
        youHave: (json['you_have'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        youNeed: (json['you_need'] as List<dynamic>? ?? [])
            .map((e) => GapSkill.fromJson(e as Map<String, dynamic>))
            .toList(),
        realityCheck: json['reality_check'] as String?,
        steps: (json['steps'] as List<dynamic>? ?? [])
            .map((e) => CompanyRoadmapStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentStep: json['current_step'] as int? ?? 0,
      );

  int get doneSteps => steps.where((s) => s.status == 'done').length;
  double get progress => steps.isEmpty ? 0 : doneSteps / steps.length;
}
