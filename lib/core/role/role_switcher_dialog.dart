import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/widgets/app_colors.dart';
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
                      'Switch Interface',
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
              'Select which portal to test (Ready-to-Sell Multi-Role App)',
              style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
            ),
            const SizedBox(height: 18),

            // 1. Customer Tile
            _roleOption(
              context,
              ref,
              role: AppRole.customer,
              title: '1. Customer Portal (الزبون)',
              subtitle: 'Shop catalog, AI Skin Consultation, Beauty Lab & Cart',
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
              title: '2. Seller / Merchant Dashboard (البائع)',
              subtitle: 'Orders management, update status, add products & stats',
              icon: Icons.storefront,
              color: Colors.amber.shade800,
              isSelected: currentRole == AppRole.seller,
              colors: colors,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            // 3. Developer Tile
            _roleOption(
              context,
              ref,
              role: AppRole.developer,
              title: '3. Developer Console (المطور)',
              subtitle: 'Supabase cloud ping, database tables, seed data & SaaS config',
              icon: Icons.terminal,
              color: Colors.blue,
              isSelected: currentRole == AppRole.developer,
              colors: colors,
              isDark: isDark,
            ),
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
  }) {
    return GestureDetector(
      onTap: () {
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
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
