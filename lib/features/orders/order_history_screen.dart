import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import 'orders_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        title: Text('My Orders',
            style: GoogleFonts.poppins(
                fontSize: 16, color: colors.text)),
      ),
      body: orders.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: colors.mutedText),
            const SizedBox(height: 12),
            Text('No orders yet',
                style: GoogleFonts.poppins(
                    fontSize: 15, color: colors.mutedText)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        separatorBuilder: (context, index) =>
        const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final o = orders[i];
          final d = o.date;
          final dateText =
              '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${o.id}',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.text)),
                    Text(dateText,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: colors.mutedText)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${o.items.length} item(s) · ${o.wilaya}',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: colors.mutedText)),
                const SizedBox(height: 6),
                for (final e in o.items)
                  Text('• ${e.product.name} x${e.quantity}',
                      style: GoogleFonts.poppins(fontSize: 12, color: colors.text)),
                const SizedBox(height: 8),
                Text('Total: ${o.total.toStringAsFixed(0)} DA',
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w700, color: colors.primary)),
              ],
            ),
          );
        },
      ),
    );
  }
}
