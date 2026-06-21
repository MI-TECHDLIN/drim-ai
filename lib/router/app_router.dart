import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_config.dart';
import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';
import 'go_router_refresh.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: AppConfig.isConfigured
      ? GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange)
      : null,
  redirect: (BuildContext context, GoRouterState state) {
    if (!AppConfig.isConfigured) return null;

    final isSplash = state.matchedLocation == '/';
    if (isSplash) return null; // Splash handles its own navigation

    final session = Supabase.instance.client.auth.currentSession;
    final isAuth = state.matchedLocation == '/auth';

    if (session == null && !isAuth) return '/auth';
    if (session != null && isAuth) return '/home';

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);
