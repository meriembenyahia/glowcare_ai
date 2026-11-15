import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/primary_button.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

/// نادي هذي الدالة في initState متاع Home
Timer? startSignupPromptTimer(BuildContext context, WidgetRef ref) {
  return Timer(const Duration(seconds: 30), () {
    if (!context.mounted) return;
    if (ref.read(authProvider) == AuthStatus.loggedIn) return;
    _showSignupDialog(context);
  });
}

void _showSignupDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard,
                size: 48, color: AppColors.deepGreen),
            const SizedBox(height: 12),
            Text(
              'Get 10% off your first order',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a free account to save your routine and unlock personalized picks.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Sign Up',
              onPressed: () {
                Navigator.of(context).pop();
                // الانتقال لصفحة Login أو Signup
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe later',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}