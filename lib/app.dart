import 'package:flutter/material.dart';
import 'package:drim_ai/router/app_router.dart';
import 'package:drim_ai/theme/app_theme.dart';

class DrimApp extends StatelessWidget {
  const DrimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Drim AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
