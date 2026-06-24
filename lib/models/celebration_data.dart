class SkillCelebrationData {
  final String skillName;
  final String category;
  final int xpEarned;
  final String? newBadgeId;

  const SkillCelebrationData({
    required this.skillName,
    required this.category,
    this.xpEarned = 50,
    this.newBadgeId,
  });
}

class StreakCelebrationData {
  final int currentStreak;
  final int bestStreak;
  final int thisMonth;
  final String? newBadgeId;

  const StreakCelebrationData({
    required this.currentStreak,
    required this.bestStreak,
    required this.thisMonth,
    this.newBadgeId,
  });
}