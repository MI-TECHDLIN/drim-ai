import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../data/quiz_repository.dart';
import '../data/roadmap_repository.dart';
import '../models/profile.dart';

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

final myProfileProvider = FutureProvider<Profile?>((ref) async {
  return ref.read(profileRepositoryProvider).getMyProfile();
});

final quizResponseProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.read(quizRepositoryProvider).getLatestResponse();
});
