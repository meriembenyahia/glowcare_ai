import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../cart/cart_provider.dart';
import 'product.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text('Product Details',
              style: GoogleFonts.poppins(
                  fontSize: 16, color: AppColors.darkText)),
          iconTheme: const IconThemeData(color: AppColors.darkText),
          actions: const [
            Icon(Icons.favorite_border, color: AppColors.darkText),
            SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.water_drop,
                    size: 80, color: AppColors.sageGreen),
              ),
              const SizedBox(height: 16),
              Text(
                product.name,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '${product.brand} · ${product.category}',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.mutedText),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(' ${product.rating}',
                      style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              const TabBar(
                labelColor: AppColors.deepGreen,
                unselectedLabelColor: AppColors.mutedText,
                indicatorColor: AppColors.deepGreen,
                tabs: [
                  Tab(text: 'Details'),
                  Tab(text: 'Ingredients'),
                  Tab(text: 'Reviews'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _TabText('Fragrance Free\nNon-Comedogenic\nDermatologist Tested\n\nProvides 24-hour hydration and helps restore the skin barrier.'),
                    _TabText('Water, Glycerin, Niacinamide, Hyaluronic Acid...'),
                    _TabText('No reviews yet.'),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(cartProvider.notifier).add(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: const Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabText extends StatelessWidget {
  final String text;
  const _TabText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 13, height: 1.6, color: AppColors.darkText),
      ),
    );
  }
}