import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// Friendly gate shown to guests on member-only AI features.
class MemberLockView extends StatelessWidget {
  final String titleKey;
  final String messageKey;

  const MemberLockView({
    super.key,
    this.titleKey = 'AI features are for members',
    this.messageKey =
        'Create a free account to unlock the AI skin advisor and the Beauty Lab assistant.',
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline, size: 40, color: colors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              s.t(titleKey),
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.t(messageKey),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.6,
                color: colors.mutedText,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: Text(s.t('Create free account')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                s.t('Sign in'),
                style: TextStyle(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
