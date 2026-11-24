import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
import '../loyalty/loyalty_card_screen.dart';
import '../loyalty/loyalty_provider.dart';
import 'order_model.dart';
import 'payment_method.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(context);
    final earnedPoints = LoyaltyState.pointsForOrder(order.subtotal);
    final paymentMethod = paymentMethodFromName(order.paymentMethod);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(size: 56),
              const SizedBox(height: 10),
              Icon(Icons.check_circle,
                  size: 64, color: colors.primary),
              const SizedBox(height: 14),
              Text(s.t('Order confirmed!'),
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 26, fontWeight: FontWeight.w600, color: colors.text)),
              const SizedBox(height: 6),
              Text(s.tf('Order #{id}', {'id': order.id}),
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: colors.mutedText)),
              const SizedBox(height: 14),
              Text(
                s.tf('Thank you {name}!\nWe will deliver to {wilaya} and call you on {phone}.', {
                  'name': order.firstName,
                  'wilaya': order.wilaya,
                  'phone': order.phone,
                }),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, height: 1.6, color: colors.text),
              ),
              const SizedBox(height: 12),
              Text(s.tf('Total: {amount}', {'amount': s.money(order.total)}),
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700, color: colors.primary)),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.mutedText.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(paymentMethod.icon,
                            size: 16, color: colors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${s.t('Payment')}: ${s.t(paymentMethod.labelKey)}',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.text),
                        ),
                      ],
                    ),
                    if (order.paymentStatus == 'pending') ...[
                      const SizedBox(height: 4),
                      Text(
                        s.t('Awaiting payment verification'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.orange.shade800),
                      ),
                    ],
                    if (order.paymentReference.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        order.paymentReference,
                        textDirection: TextDirection.ltr,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: colors.mutedText),
                      ),
                    ],
                  ],
                ),
              ),

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
                              s.tf('+{points} Points Loyalty Earned!', {
                                'points': '$earnedPoints'
                              }),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.text,
                              ),
                            ),
                            Text(
                              s.t('Credited to your GlowCare Loyalty Card'),
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
                  child: Text(s.t('Back to Home'), style: const TextStyle(fontWeight: FontWeight.w600)),
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
                  label: Text(s.t('View My Loyalty Card (Carte de Fidélité)')),
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
