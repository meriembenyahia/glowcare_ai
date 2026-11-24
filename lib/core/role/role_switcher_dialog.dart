import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../localization/app_strings.dart';
import '../theme/widgets/app_colors.dart';
import 'role_access.dart';
import 'role_provider.dart';

class RoleSwitcherDialog extends ConsumerWidget {
  const RoleSwitcherDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const RoleSwitcherDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRole = ref.watch(roleProvider);
    final authStatus = ref.watch(authProvider);
    final loggedIn = authStatus == AuthStatus.loggedIn;
    final isAdmin = isAdminEmail(ref.read(authProvider.notifier).userEmail);
    final s = AppStrings.of(context);

    return Dialog(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.hub, color: colors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      s.t('Switch Interface'),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.mutedText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              s.t('Select which portal to test (Ready-to-Sell Multi-Role App)'),
              style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
            ),
            const SizedBox(height: 18),

            // 1. Customer Tile
            _roleOption(
              context,
              ref,
              role: AppRole.customer,
              title: s.t('1. Customer Portal (الزبون)'),
              subtitle: s.t('Shop catalog, AI Skin Consultation, Beauty Lab & Cart'),
              icon: Icons.person_outline,
              color: colors.primary,
              isSelected: currentRole == AppRole.customer,
              colors: colors,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            // 2. Seller Tile
            _roleOption(
              context,
              ref,
              role: AppRole.seller,
              title: s.t('2. Seller / Merchant Dashboard (البائع)'),
              subtitle: s.t('Orders management, update status, add products & stats'),
              icon: Icons.storefront,
              color: Colors.amber.shade800,
              isSelected: currentRole == AppRole.seller,
              colors: colors,
              isDark: isDark,
              lockedMessage: s.t('Sign in to unlock the seller dashboard'),
              locked: !loggedIn,
            ),
            const SizedBox(height: 10),

            // 3. Developer Tile
            _roleOption(
              context,
              ref,
              role: AppRole.developer,
              title: s.t('3. Developer Console (المطور)'),
              subtitle: s.t('Supabase cloud ping, database tables, seed data & SaaS config'),
              icon: Icons.terminal,
              color: Colors.blue,
              isSelected: currentRole == AppRole.developer,
              colors: colors,
              isDark: isDark,
              lockedMessage: s.t('Developer console is restricted to the store administrator'),
              locked: !isAdmin,
            ),
            if (!loggedIn) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.login, size: 18),
                  label: Text(s.t('Sign in')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _roleOption(
    BuildContext context,
    WidgetRef ref, {
    required AppRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required AppThemeColors colors,
    required bool isDark,
    bool locked = false,
    String? lockedMessage,
  }) {
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: GestureDetector(
        onTap: () {
          if (locked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(lockedMessage ?? ''),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          ref.read(roleProvider.notifier).setRole(role);
          Navigator.of(context).pop();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: isDark ? 0.25 : 0.12)
                : colors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? color : colors.primary.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: colors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              if (locked)
                Icon(Icons.lock_outline, color: colors.mutedText, size: 18)
              else if (isSelected)
                Icon(Icons.check_circle, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
