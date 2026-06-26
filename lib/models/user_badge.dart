class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

const kBadgeDefinitions = <String, BadgeDefinition>{
  'first_step': BadgeDefinition(
    id: 'first_step',
    name: 'First Step',
    description: 'Started your first skill',
    emoji: '👟',
  ),
  'iron_discipline': BadgeDefinition(
    id: 'iron_discipline',
    name: 'Iron Discipline',
    description: 'Streak warrior badge',
    emoji: '🛡️',
  ),
  'dream_chaser': BadgeDefinition(
    id: 'dream_chaser',
    name: 'Dream Chaser',
    description: 'Started a dream company roadmap',
    emoji: '🚀',
  ),
  'confident': BadgeDefinition(
    id: 'confident',
    name: 'Confident',
    description: 'Confidence score reached 8+',
    emoji: '⭐',
  ),
  'pathfinder': BadgeDefinition(
    id: 'pathfinder',
    name: 'Pathfinder',
    description: 'Completed the full Drim AI journey',
    emoji: '🧭',
  ),
  'skill_master': BadgeDefinition(
    id: 'skill_master',
    name: 'Skill Master',
    description: 'Completed 5 skills',
    emoji: '🎯',
  ),
};

class UserBadge {
  final String id;
  final String badgeId;
  final DateTime earnedAt;

  const UserBadge({
    required this.id,
    required this.badgeId,
    required this.earnedAt,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) => UserBadge(
    id: json['id'] as String,
    badgeId: json['badge_id'] as String,
    earnedAt: DateTime.parse(json['earned_at'] as String),
  );

  BadgeDefinition? get definition => kBadgeDefinitions[badgeId];
}
