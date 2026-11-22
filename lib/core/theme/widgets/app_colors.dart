import 'package:flutter/material.dart';

class AppColors {
  static const sageGreen = Color(0xFF688F7A);
  static const deepGreen = Color(0xFF4E6F52); // لون الأزرار في التصميم
  static const cream = Color(0xFFE8E8DC);
  static const background = Color(0xFFF6F3EA);
  static const peachPink = Color(0xFFF3D7D9);
  static const white = Color(0xFFFFFFFF);
  static const darkText = Color(0xFF303D3D);
  static const mutedText = Color(0xFF8A948F);
}

class AppThemeColors {
  final Color background;
  final Color cardBackground;
  final Color text;
  final Color mutedText;
  final Color primary;
  final Color inputFill;

  const AppThemeColors({
    required this.background,
    required this.cardBackground,
    required this.text,
    required this.mutedText,
    required this.primary,
    required this.inputFill,
  });

  static AppThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const AppThemeColors(
        background: Color(0xFF141D1A),
        cardBackground: Color(0xFF1E2B27),
        text: Color(0xFFE6EFEA),
        mutedText: Color(0xFF9AA7A0),
        primary: Color(0xFF688F7A),
        inputFill: Color(0xFF1E2B27),
      );
    }
    return const AppThemeColors(
      background: AppColors.background,
      cardBackground: AppColors.white,
      text: AppColors.darkText,
      mutedText: AppColors.mutedText,
      primary: AppColors.deepGreen,
      inputFill: AppColors.white,
    );
  }
}
