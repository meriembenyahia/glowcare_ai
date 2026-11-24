import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_bar_title.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import 'loyalty_provider.dart';

class LoyaltyCardScreen extends ConsumerWidget {
  const LoyaltyCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyalty = ref.watch(loyaltyProvider);
    final authStatus = ref.watch(authProvider);
    final isLoggedIn = authStatus == AuthStatus.loggedIn;
    final userEmail = ref.read(authProvider.notifier).userEmail;
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);

    final tier = loyalty.tier;
    final points = loyalty.totalPoints;
    final nextThreshold = tier.nextTierThreshold;
    final currentMin = tier.currentMin;
    final progress = tier == LoyaltyTier.platinum
        ? 1.0
        : (points - currentMin) / (nextThreshold - currentMin);
    final ptsToNext = tier == LoyaltyTier.platinum
        ? 0
        : nextThreshold - points;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
        title: AppBarTitle(
          text: s.t('Carte de Fidélité (Loyalty Card)'),
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: s.t('Add +150 Demo Points'),
            onPressed: () {
              ref.read(loyaltyProvider.notifier).addPoints(15000);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(s.t('🎉 +150 Loyalty Points added to your card!')),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── The Card ──────────────────────────────────────────
            _GlowCard(
              tier: tier,
              points: points,
              memberName: isLoggedIn && userEmail.isNotEmpty ? userEmail : s.t('VIP Guest Member'),
            ),
            const SizedBox(height: 16),

            // ── Sign-in tip if guest ──────────────────────────────
            if (!isLoggedIn)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_open, color: colors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.t('Sign in to sync your points and discounts across all devices.'),
                        style: GoogleFonts.poppins(fontSize: 11, color: colors.text),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: Text(s.t('Sign In'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

            // ── Progress to next tier ─────────────────────────────
            if (tier != LoyaltyTier.platinum) ...[
              Text(
                s.tf('Progress to {tier}', {'tier': s.t(_nextTierName(tier))}),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: colors.inputFill,
                  color: _tierColor(tier),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.tf('{pts} pts needed to reach {tier} Tier', {
                  'pts': '$ptsToNext',
                  'tier': '${tier.emoji} ${s.t(_nextTierName(tier))}',
                }),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: colors.mutedText,
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2FBE).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.t("You've reached the highest tier — Platinum VIP! Enjoy 15% off all orders and free express delivery."),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF7B2FBE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Benefits ──────────────────────────────────────────
            Text(
              s.tf('{tier} Member Privileges', {
                'tier': '${tier.emoji} ${s.t(tier.label)}',
              }),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 10),
            ...tier.benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 18, color: _tierColor(tier)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.t(b),
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: colors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── How to earn ───────────────────────────────────────
            _InfoCard(
              colors: colors,
              icon: Icons.info_outline,
              title: s.t('Comment accumuler des points ? (How it works)'),
              body: s.t(
                  '• 1 point accumulé pour chaque 100 DA dépensés\n'
                  '• Points crédités automatiquement à chaque commande confirmée\n'
                  '• Paliers : 500 pts → Silver · 1000 pts → Gold · 2000 pts → Platinum 💎\n'
                  '• Remises directes sur vos prochains achats !'),
            ),
            const SizedBox(height: 20),

            // ── Points history ────────────────────────────────────
            Text(
              s.t('Points History'),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 10),
            loyalty.history.isEmpty
                ? _InfoCard(
                    colors: colors,
                    icon: Icons.receipt_long_outlined,
                    title: s.t('No points history yet'),
                    body: s.t('Pass your first order to collect points, or tap + in the top bar to test points!'),
                  )
                : Column(
                    children: [
                      for (final entry in loyalty.history.take(10))
                        _HistoryTile(entry: entry, colors: colors),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  String _nextTierName(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:   return 'Silver';
      case LoyaltyTier.silver:   return 'Gold';
      case LoyaltyTier.gold:     return 'Platinum';
      default:                   return '';
    }
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

// ─────────────────────────────────────────────
//  Beautiful Glow Card widget with Barcode & Member ID
// ─────────────────────────────────────────────
class _GlowCard extends StatelessWidget {
  final LoyaltyTier tier;
  final int points;
  final String memberName;

  const _GlowCard({
    required this.tier,
    required this.points,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final gradients = {
      LoyaltyTier.bronze: [const Color(0xFFCD7F32), const Color(0xFF8B5E3C)],
      LoyaltyTier.silver: [const Color(0xFFBDBDBD), const Color(0xFF757575)],
      LoyaltyTier.gold: [const Color(0xFFFFB300), const Color(0xFFFF6F00)],
      LoyaltyTier.platinum: [const Color(0xFF7B2FBE), const Color(0xFF4A148C)],
    };
    final colors = gradients[tier]!;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.spa, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          s.t('GlowCare Club'),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tier.emoji} ${s.t(tier.label).toUpperCase()}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$points',
                      style: GoogleFonts.poppins(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        s.t('POINTS'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          letterSpacing: 1.5,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            s.tf('CARD # {number}', {
                              'number': 'GC-${(points + 1042).toString().padLeft(6, '0')}'
                            }),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white70,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Digital Barcode simulation
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code, size: 20, color: colors[1]),
                          const SizedBox(width: 4),
                          Text(
                            '|||||||||',
                            style: TextStyle(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: colors[1],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  History tile
// ─────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final PointEntry entry;
  final AppThemeColors colors;
  const _HistoryTile({required this.entry, required this.colors});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isPositive = entry.points > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPositive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
            ),
            child: Icon(
              isPositive ? Icons.add : Icons.remove,
              color: isPositive ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.pointReason(entry.reason),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
                Text(
                  _formatDate(entry.date),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: colors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${entry.points} ${s.t('pts')}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ─────────────────────────────────────────────
//  Info card
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final AppThemeColors colors;
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard({
    required this.colors,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.mutedText, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: colors.mutedText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
