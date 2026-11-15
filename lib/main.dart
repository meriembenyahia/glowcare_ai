import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/widgets/app_theme.dart';
import 'features/onboarding/splash_screen.dart';

void main() => runApp(const ProviderScope(child: GlowCareApp()));

class GlowCareApp extends StatelessWidget {
  const GlowCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlowCare AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
