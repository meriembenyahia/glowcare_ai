import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_bg.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.7),
                  AppColors.background.withValues(alpha: 0.0),
                  AppColors.background.withValues(alpha: 0.0),
                  AppColors.background.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const AppLogo(size: 120),
                const SizedBox(height: 10),
                Text(
                  'GlowCare AI',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.t('Healthy Skin  ✦  Natural Beauty'),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                Text(
                  s.t('Your personalized\nskincare & makeup companion'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}