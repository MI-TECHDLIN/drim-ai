import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/activity_repository.dart';
import '../data/auth_repository.dart';
import '../data/badge_repository.dart';
import '../data/dream_company_repository.dart';
import '../data/goal_repository.dart';
import '../data/opportunities_repository.dart';
import '../data/profile_repository.dart';
import '../data/quiz_repository.dart';
import '../data/roadmap_repository.dart';
import '../data/skill_progress_repository.dart';
import '../models/career_match.dart';
import '../models/dashboard_data.dart';
import '../models/dream_company_goal.dart';
import '../models/profile.dart';
import '../models/user_goal.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);
final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepository(),
);
final roadmapRepositoryProvider = Provider<RoadmapRepository>(
  (ref) => RoadmapRepository(),
);
final opportunitiesRepositoryProvider = Provider<OpportunitiesRepository>(
  (ref) => OpportunitiesRepository(),
);
final skillProgressRepositoryProvider = Provider<SkillProgressRepository>(
  (ref) => SkillProgressRepository(),
);
final dreamCompanyRepositoryProvider = Provider<DreamCompanyRepository>(
  (ref) => DreamCompanyRepository(),
);
final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(),
);
final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(),
);
final badgeRepositoryProvider = Provider<BadgeRepository>(
  (ref) => BadgeRepository(),
);

final myProfileProvider = FutureProvider<Profile?>((ref) async {
  return ref.read(profileRepositoryProvider).getMyProfile();
});

final quizResponseProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.read(quizRepositoryProvider).getLatestResponse();
});

final careerMatchProvider = FutureProvider.family<CareerMatch?, String>((
  ref,
  matchId,
) async {
  return ref.read(roadmapRepositoryProvider).getMatch(matchId);
});

final jobListingsProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  title,
) async {
  return ref.read(opportunitiesRepositoryProvider).fetchJobs(title);
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final roadmapRepo = ref.read(roadmapRepositoryProvider);
  final profileRepo = ref.read(profileRepositoryProvider);
  final skillRepo = ref.read(skillProgressRepositoryProvider);

  final results = await Future.wait([
    roadmapRepo.getSavedMatch(),
    profileRepo.getConfidenceScores(),
  ]);

  final savedMatch = results[0] as CareerMatch?;
  final scores = results[1] as Map<String, int?>;

  List skills = [];
  if (savedMatch != null) {
    skills = await skillRepo.getSkills(savedMatch.id);
  }

  return DashboardData(
    savedMatch: savedMatch,
    skills: skills.cast(),
    preScore: scores['pre'],
    postScore: scores['post'],
  );
});

final activeGoalProvider = FutureProvider<UserGoal?>((ref) async {
  return ref.read(goalRepositoryProvider).getActiveGoal();
});

final activeDreamGoalProvider = FutureProvider<DreamCompanyGoal?>((ref) async {
  return ref.read(dreamCompanyRepositoryProvider).getActiveGoal();
});

final activityMapProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.read(activityRepositoryProvider).getActivityMap();
});

final streakDataProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.read(activityRepositoryProvider);
  final results = await Future.wait([
    repo.getCurrentStreak(),
    repo.getBestStreak(),
    repo.getThisMonthCount(),
    repo.getWeeklyScore(),
  ]);
  return {
    'current': results[0],
    'best': results[1],
    'thisMonth': results[2],
    'weeklyScore': results[3],
  };
});

final userBadgesProvider = FutureProvider((ref) async {
  return ref.read(badgeRepositoryProvider).getMyBadges();
});
