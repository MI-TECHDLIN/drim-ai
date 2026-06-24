import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_config.dart';
import '../features/activity/activity_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/career_detail/career_detail_screen.dart';
import '../features/celebration/skill_celebration_screen.dart';
import '../features/celebration/streak_celebration_screen.dart';
import '../features/confidence/confidence_check_screen.dart';
import '../features/confidence/confidence_delta_screen.dart';
import '../features/dream_job/company_roadmap_screen.dart';
import '../features/dream_job/dream_job_search_screen.dart';
import '../features/dream_job/gap_analysis_screen.dart';
import '../features/goal/goal_setup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/jobs/job_listings_screen.dart';
import '../features/onboarding/onboarding_carousel_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/roadmap/roadmap_screen.dart';
import '../features/skills/skills_tracker_screen.dart';
import '../features/splash/splash_screen.dart';
import '../models/career_match.dart';
import '../models/celebration_data.dart';
import '../models/dream_company_goal.dart';
import 'go_router_refresh.dart';

const _publicRoutes = ['/', '/onboarding-intro', '/auth'];

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: AppConfig.isConfigured
      ? GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange)
      : null,
  redirect: (BuildContext context, GoRouterState state) {
    if (!AppConfig.isConfigured) return null;
    final loc = state.matchedLocation;
    if (_publicRoutes.contains(loc)) return null;
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return '/auth';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(
      path: '/onboarding-intro',
      builder: (_, __) => const OnboardingCarouselScreen(),
    ),
    GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(
      path: '/confidence-pre',
      builder: (_, __) => const ConfidenceCheckScreen(phase: 'pre'),
    ),
    GoRoute(
      path: '/confidence-post',
      builder: (_, __) => const ConfidenceCheckScreen(phase: 'post'),
    ),
    GoRoute(
      path: '/confidence-delta',
      builder: (_, __) => const ConfidenceDeltaScreen(),
    ),
    GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen()),
    GoRoute(path: '/roadmap', builder: (_, __) => const RoadmapScreen()),
    GoRoute(
      path: '/career/:matchId',
      builder: (context, state) => CareerDetailScreen(
        matchId: state.pathParameters['matchId']!,
        initialMatch: state.extra as CareerMatch?,
      ),
    ),
    GoRoute(
      path: '/skills/:matchId',
      builder: (context, state) => SkillsTrackerScreen(
        matchId: state.pathParameters['matchId']!,
        initialMatch: state.extra as CareerMatch?,
      ),
    ),
    GoRoute(
      path: '/jobs/:title',
      builder: (context, state) => JobListingsScreen(
        careerTitle: Uri.decodeComponent(state.pathParameters['title']!),
      ),
    ),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/activity', builder: (_, __) => const ActivityScreen()),
    GoRoute(
      path: '/dream-job',
      builder: (_, __) => const DreamJobSearchScreen(),
    ),
    GoRoute(
      path: '/gap-analysis',
      builder: (context, state) =>
          GapAnalysisScreen(goal: state.extra as DreamCompanyGoal),
    ),
    GoRoute(
      path: '/company-roadmap/:goalId',
      builder: (context, state) => CompanyRoadmapScreen(
        goalId: state.pathParameters['goalId']!,
        initialGoal: state.extra as DreamCompanyGoal?,
      ),
    ),
    GoRoute(path: '/goal-setup', builder: (_, __) => const GoalSetupScreen()),
    GoRoute(
      path: '/celebration/skill',
      builder: (context, state) => SkillCelebrationScreen(
        data: state.extra is SkillCelebrationData
            ? state.extra as SkillCelebrationData
            : const SkillCelebrationData(
                skillName: 'Skill unlocked',
                category: 'Career skill',
              ),
      ),
    ),
    GoRoute(
      path: '/celebration/streak',
      builder: (context, state) => StreakCelebrationScreen(
        data: state.extra is StreakCelebrationData
            ? state.extra as StreakCelebrationData
            : const StreakCelebrationData(
                currentStreak: 0,
                bestStreak: 0,
                thisMonth: 0,
              ),
      ),
    ),
  ],
);
