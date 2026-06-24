import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_config.dart';
import '../features/auth/auth_screen.dart';
import '../features/career_detail/career_detail_screen.dart';
import '../features/confidence/confidence_check_screen.dart';
import '../features/confidence/confidence_delta_screen.dart';
import '../features/home/home_screen.dart';
import '../features/jobs/job_listings_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/roadmap/roadmap_screen.dart';
import '../features/skills/skills_tracker_screen.dart';
import '../features/splash/splash_screen.dart';
import '../models/career_match.dart';
import 'go_router_refresh.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: AppConfig.isConfigured
      ? GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange)
      : null,
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We could not open that screen.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(state.matchedLocation),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  },
  redirect: (BuildContext context, GoRouterState state) {
    if (!AppConfig.isConfigured) return null;
    final isSplash = state.matchedLocation == '/';
    if (isSplash) return null;
    final session = Supabase.instance.client.auth.currentSession;
    final isAuth = state.matchedLocation == '/auth';
    if (session == null && !isAuth) return '/auth';
    if (session != null && isAuth) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
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
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        final match = state.extra as CareerMatch?;
        return CareerDetailScreen(matchId: matchId, initialMatch: match);
      },
    ),
    GoRoute(
      path: '/skills/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        final match = state.extra as CareerMatch?;
        return SkillsTrackerScreen(matchId: matchId, initialMatch: match);
      },
    ),
    GoRoute(
      path: '/jobs/:title',
      builder: (context, state) {
        final title = Uri.decodeComponent(state.pathParameters['title']!);
        return JobListingsScreen(careerTitle: title);
      },
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
  ],
);
