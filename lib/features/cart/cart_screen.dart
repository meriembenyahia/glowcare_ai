import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/product_image.dart';
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
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        title: Text('My Cart (${items.length})',
            style: GoogleFonts.poppins(
                fontSize: 16, color: colors.text)),
      ),
      body: items.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 64, color: colors.mutedText),
            const SizedBox(height: 12),
            Text('Your cart is empty',
                style: GoogleFonts.poppins(
                    fontSize: 15, color: colors.mutedText)),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 10),
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
                          child: ProductImage(path: e.product.image, size: 56),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(e.product.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colors.text)),
                              Text(e.product.brand,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: colors.mutedText)),
                              Text(
                                  '${(e.product.price * e.quantity).toStringAsFixed(0)} DA',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colors.primary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: colors.text),
                          onPressed: () =>
                              notifier.decrease(e.product.id),
                        ),
                        Text('${e.quantity}', style: TextStyle(color: colors.text)),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: colors.text),
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
            _row(context, 'Subtotal', subtotal),
            _row(context, 'Delivery', delivery),
            const Divider(),
            _row(context, 'Total', subtotal + delivery, bold: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const CheckoutScreen()),
              ),
              child: const Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, double value, {bool bold = false}) {
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
