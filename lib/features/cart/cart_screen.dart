import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/product_image.dart';
import '../loyalty/loyalty_card_screen.dart';
import '../loyalty/loyalty_provider.dart';
import '../orders/checkout_screen.dart';
import 'cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final subtotal = notifier.subtotal;
    const delivery = 500.0;
    final total = subtotal + delivery;
    final colors = AppThemeColors.of(context);

    // Loyalty
    final loyalty = ref.watch(loyaltyProvider);
    final earnedPts = LoyaltyState.pointsForOrder(total);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        title: Text(
          'My Cart (${items.length})',
          style: GoogleFonts.poppins(fontSize: 16, color: colors.text),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 64, color: colors.mutedText),
                  const SizedBox(height: 12),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: colors.mutedText),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Cart items ──────────────────────────────────────
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final e = items[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ProductImage(
                                    path: e.product.image, size: 56),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.product.name,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colors.text),
                                    ),
                                    Text(
                                      e.product.brand,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: colors.mutedText),
                                    ),
                                    Text(
                                      '${(e.product.price * e.quantity).toStringAsFixed(0)} DA',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colors.primary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: colors.text),
                                onPressed: () =>
                                    notifier.decrease(e.product.id),
                              ),
                              Text('${e.quantity}',
                                  style: TextStyle(color: colors.text)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: colors.text),
                                onPressed: () =>
                                    notifier.increase(e.product.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    notifier.remove(e.product.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Loyalty points banner ───────────────────────────
                  if (earnedPts > 0) ...[
                    const SizedBox(height: 10),
                    _LoyaltyBanner(
                      earnedPts: earnedPts,
                      currentPts: loyalty.totalPoints,
                      tier: loyalty.tier,
                    ),
                  ],

                  // ── Totals ──────────────────────────────────────────
                  const SizedBox(height: 10),
                  _row(context, 'Subtotal', subtotal),
                  _row(context, 'Delivery', delivery),
                  const Divider(),
                  _row(context, 'Total', total, bold: true),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const CheckoutScreen()),
                      ),
                      child: Text(
                        'Proceed to Checkout',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _row(BuildContext context, String label, double value,
      {bool bold = false}) {
    final colors = AppThemeColors.of(context);
    final style = GoogleFonts.poppins(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? colors.primary : colors.text,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${value.toStringAsFixed(0)} DA', style: style),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Loyalty banner in cart
// ─────────────────────────────────────────────
class _LoyaltyBanner extends StatelessWidget {
  final int earnedPts;
  final int currentPts;
  final LoyaltyTier tier;
  const _LoyaltyBanner({
    required this.earnedPts,
    required this.currentPts,
    required this.tier,
  });

  Color _tierColor() {
    switch (tier) {
      case LoyaltyTier.bronze:   return const Color(0xFFCD7F32);
      case LoyaltyTier.silver:   return const Color(0xFF9E9E9E);
      case LoyaltyTier.gold:     return const Color(0xFFFFB300);
      case LoyaltyTier.platinum: return const Color(0xFF7B2FBE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoyaltyCardScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _tierColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _tierColor().withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(tier.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.poppins(fontSize: 12, color: _tierColor()),
                  children: [
                    const TextSpan(
                      text: 'You\'ll earn ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: '+$earnedPts pts',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: ' with this order  •  Total: ${currentPts + earnedPts} pts',
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: _tierColor()),
          ],
        ),
      ),
    );
  }
}
