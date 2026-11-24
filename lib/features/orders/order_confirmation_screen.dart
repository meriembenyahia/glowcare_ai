import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../loyalty/loyalty_card_screen.dart';
import '../loyalty/loyalty_provider.dart';
import 'order_model.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final earnedPoints = LoyaltyState.pointsForOrder(order.subtotal);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  size: 80, color: colors.primary),
              const SizedBox(height: 14),
              Text('Order confirmed!',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 26, fontWeight: FontWeight.w600, color: colors.text)),
              const SizedBox(height: 6),
              Text('Order #${order.id}',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: colors.mutedText)),
              const SizedBox(height: 14),
              Text(
                'Thank you ${order.firstName}!\nWe will deliver to ${order.wilaya} and call you on ${order.phone}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, height: 1.6, color: colors.text),
              ),
              const SizedBox(height: 12),
              Text('Total: ${order.total.toStringAsFixed(0)} DA',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700, color: colors.primary)),

              // Loyalty points notification card
              if (earnedPoints > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+$earnedPoints Points Loyalty Earned!',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.text,
                              ),
                            ),
                            Text(
                              'Credited to your GlowCare Loyalty Card',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: colors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: isDark ? const Color(0xFF141D1A) : AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoyaltyCardScreen()),
                    );
                  },
                  icon: const Icon(Icons.card_membership, size: 18),
                  label: const Text('View My Loyalty Card (Carte de Fidélité)'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.primary),
                    foregroundColor: colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
