import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/role/role_access.dart';
import '../../core/role/role_provider.dart';
import '../../core/role/role_switcher_dialog.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/widgets/app_bar_title.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../ingredients/ingredient_checker_screen.dart';
import '../loyalty/loyalty_card_screen.dart';
import '../loyalty/loyalty_provider.dart';
import '../ai_advisor/ai_settings_dialog.dart';
import '../orders/order_history_screen.dart';
import '../routine/routine_screen.dart';
import '../shop/shop_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final isLoggedIn = authStatus == AuthStatus.loggedIn;
    final auth = ref.read(authProvider.notifier);
    final userEmail = auth.userEmail;
    final loyalty = ref.watch(loyaltyProvider);
    final locale = ref.watch(localeProvider);
    final strings = AppStrings.of(context);
    final colors = AppThemeColors.of(context);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    final langName = locale.languageCode == 'ar'
        ? '🇩🇿 العربية (Arabic)'
        : locale.languageCode == 'fr'
            ? '🇫🇷 Français'
            : '🇬🇧 English';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: AppBarTitle(
          text: strings.myProfile,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. بطاقة الصورة الشخصية والمعلومات
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.sageGreen.withValues(alpha: 0.25),
                      child: Icon(
                        Icons.person_outline,
                        size: 38,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn ? strings.memberUser : strings.guestUser,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoggedIn ? userEmail : strings.t('Sign in to sync your routine & orders'),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: colors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // VIP Carte de Fidélité Banner
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoyaltyCardScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _tierColor(loyalty.tier),
                        _tierColor(loyalty.tier).withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _tierColor(loyalty.tier).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(loyalty.tier.emoji, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  strings.t('Carte de Fidélité'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '• ${strings.t(loyalty.tier.label)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.tf('{points} pts accumulés • Remises & cadeaux', {
                                'points': '${loyalty.totalPoints}',
                              }),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          strings.t('Ouvrir'),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _tierColor(loyalty.tier),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. اختصارات سريعة
              Text(
                strings.shortcuts,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _shortcutTile(
                      context,
                      icon: Icons.receipt_long_outlined,
                      label: strings.myOrders,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _shortcutTile(
                      context,
                      icon: Icons.favorite_border,
                      label: strings.wishlist,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ShopScreen(initialCategory: 'Favorites ❤️'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _shortcutTile(
                      context,
                      icon: Icons.calendar_month_outlined,
                      label: strings.navRoutine,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RoutineScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _shortcutTile(
                      context,
                      icon: Icons.science_outlined,
                      label: strings.navBeautyLab,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const IngredientCheckerScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _shortcutTile(
                      context,
                      icon: Icons.card_membership,
                      label: strings.loyaltyCardTitle,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoyaltyCardScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _shortcutTile(
                      context,
                      icon: Icons.psychology_outlined,
                      label: strings.t('ChatGPT Setup'),
                      onTap: () => AiSettingsDialog.show(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. تبديل دور التطبيق (Multi-Role Portal)
              if (isLoggedIn) ...[
                Text(
                  strings.t('Application Interface (جاهز للبيع - 3 أدوار)'),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 12),
                _roleCard(context, ref, colors),
                const SizedBox(height: 24),
              ],

              // 4. إعدادات الحساب
              Text(
                strings.t('Account Settings'),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 12),
              _settingsTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: strings.t('Dark Mode'),
                subtitle: isDark
                    ? strings.t('Dark theme enabled')
                    : strings.t('Light theme enabled'),
                trailing: Switch(
                  value: isDark,
                  activeTrackColor: colors.primary,
                  onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => LanguagePickerDialog.show(context),
                borderRadius: BorderRadius.circular(16),
                child: _settingsTile(
                  context,
                  icon: Icons.language_outlined,
                  title: strings.language,
                  subtitle: langName,
                  trailing: Icon(strings.chevronIcon(context), size: 16, color: colors.mutedText),
                ),
              ),
              const SizedBox(height: 10),
              _settingsTile(
                context,
                icon: Icons.location_on_outlined,
                title: strings.deliveryAddress,
                subtitle: strings.algeriaCoverage,
              ),
              const SizedBox(height: 10),
              _settingsTile(
                context,
                icon: Icons.shield_outlined,
                title: strings.t('Privacy & Security'),
                subtitle: strings.t('Protected by Supabase RLS'),
              ),
              const SizedBox(height: 24),

              // 4. زر تسجيل الدخول أو الخروج
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isLoggedIn) {
                      ref.read(authProvider.notifier).logOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.t('Logged out successfully.'))),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoggedIn ? Colors.redAccent.shade100 : colors.primary,
                    foregroundColor: isLoggedIn ? Colors.red.shade900 : AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(isLoggedIn ? Icons.logout : Icons.login, size: 20),
                  label: Text(
                    isLoggedIn ? strings.signOut : strings.signIn,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, WidgetRef ref, AppThemeColors colors) {
    final currentRole = ref.watch(roleProvider);
    final isAdmin = isAdminEmail(ref.read(authProvider.notifier).userEmail);
    final s = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    currentRole == AppRole.customer
                        ? Icons.person_outline
                        : currentRole == AppRole.seller
                            ? Icons.storefront
                            : Icons.terminal,
                    color: colors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.t(currentRole.title),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => RoleSwitcherDialog.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: Text(s.t('Switch'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.t(currentRole.description),
            style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
          ),
          const SizedBox(height: 12),

          // 3 Quick switcher buttons
          Row(
            children: [
              _rolePill(context, ref, AppRole.customer, s.t('Customer'), Icons.shopping_bag_outlined, currentRole == AppRole.customer, colors),
              const SizedBox(width: 8),
              _rolePill(context, ref, AppRole.seller, s.t('Seller'), Icons.storefront, currentRole == AppRole.seller, colors),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                _rolePill(context, ref, AppRole.developer, s.t('Dev'), Icons.terminal, currentRole == AppRole.developer, colors),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _rolePill(
    BuildContext context,
    WidgetRef ref,
    AppRole role,
    String label,
    IconData icon,
    bool isSelected,
    AppThemeColors colors,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(roleProvider.notifier).setRole(role);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.primary : colors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.white : colors.text,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.white : colors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shortcutTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = AppThemeColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final colors = AppThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.mutedText, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Color _tierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:   return const Color(0xFFCD7F32);
      case LoyaltyTier.silver:   return const Color(0xFF9E9E9E);
      case LoyaltyTier.gold:     return const Color(0xFFFFB300);
      case LoyaltyTier.platinum: return const Color(0xFF7B2FBE);
    }
  }
}
