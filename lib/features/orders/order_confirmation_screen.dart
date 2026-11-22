import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import 'order_model.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  size: 90, color: AppColors.deepGreen),
              const SizedBox(height: 16),
              Text('Order confirmed!',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 26, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Order #${order.id}',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.mutedText)),
              const SizedBox(height: 16),
              Text(
                'Thank you ${order.firstName}!\nWe will deliver to ${order.wilaya} and call you on ${order.phone}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 12),
              Text('Total: ${order.total.toStringAsFixed(0)} DA',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}