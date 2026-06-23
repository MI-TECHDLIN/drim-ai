import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/opportunities_repository.dart';
import '../data/profile_repository.dart';
import '../data/quiz_repository.dart';
import '../data/roadmap_repository.dart';
import '../data/skill_progress_repository.dart';
import '../models/career_match.dart';
import '../models/dashboard_data.dart';
import '../models/profile.dart';
import '../models/skill_progress.dart';

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

  List<SkillProgress> skills = [];
  if (savedMatch != null) {
    skills = await skillRepo.getSkills(savedMatch.id);
  }

  return DashboardData(
    savedMatch: savedMatch,
    skills: skills,
    preScore: scores['pre'],
    postScore: scores['post'],
  );
});
