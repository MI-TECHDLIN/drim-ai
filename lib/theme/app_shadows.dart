import 'package:flutter/material.dart';
import 'app_colors.dart';

// Neo-brutalism shadow tokens
abstract class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: AppColors.border,
    offset: Offset(0, -2),
    blurRadius: 8,
  );

  static const BoxShadow hard = BoxShadow(
    color: AppColors.border,
    offset: Offset(4, 4),
    blurRadius: 0,
  );

  static const BoxShadow hardSm = BoxShadow(
    color: AppColors.border,
    offset: Offset(3, 3),
    blurRadius: 0,
  );

  static const BoxShadow hardLg = BoxShadow(
    color: AppColors.border,
    offset: Offset(6, 6),
    blurRadius: 0,
  );
}
