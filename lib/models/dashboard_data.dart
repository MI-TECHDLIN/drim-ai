import 'career_match.dart';
import 'skill_progress.dart';

class DashboardData {
  final CareerMatch? savedMatch;
  final List<SkillProgress> skills;
  final int? preScore;
  final int? postScore;

  const DashboardData({
    this.savedMatch,
    this.skills = const [],
    this.preScore,
    this.postScore,
  });

  int get doneCount => skills.where((s) => s.status == 'done').length;
  int get inProgressCount =>
      skills.where((s) => s.status == 'learning').length + doneCount;
  int get totalSkills => skills.length;

  double get skillProgress =>
      totalSkills == 0 ? 0.0 : inProgressCount / totalSkills;

  SkillProgress? get nextSkill {
    final learning = skills.where((s) => s.status == 'learning').toList();
    if (learning.isNotEmpty) return learning.first;
    final notStarted = skills.where((s) => s.status == 'not_started').toList();
    if (notStarted.isNotEmpty) return notStarted.first;
    return null;
  }

  int nextSkillIndex(SkillProgress skill) => skills.indexOf(skill) + 1;

  int? get confidenceDelta {
    if (preScore == null || postScore == null) return null;
    return postScore! - preScore!;
  }
}
