import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import 'product.dart';
import 'product_details_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const _categories = ['All', 'Skincare', 'Makeup', 'Hair Care', 'Fragrance'];
  String _selected = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final products = sampleProducts.where((p) {
      final matchCat = _selected == 'All' || p.category == _selected;
      final q = _query.toLowerCase();
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
      return matchCat && matchQuery;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shop',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),

              // البحث
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search products or brands...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.mutedText, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // فلتر الفئات
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final active = cat == _selected;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: active,
                      onSelected: (_) => setState(() => _selected = cat),
                      selectedColor: AppColors.deepGreen,
                      backgroundColor: AppColors.white,
                      side: BorderSide.none,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: active ? AppColors.white : AppColors.darkText,
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // الشبكة
              Expanded(
                child: products.isEmpty
                    ? Center(
                  child: Text(
                    'No products found',
                    style: GoogleFonts.poppins(color: AppColors.mutedText),
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: products.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: products[i]),
                      ),
                    ),
                    child: _ShopCard(product: products[i]),
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

class _ShopCard extends StatelessWidget {
  final Product product;
  const _ShopCard({required this.product});

  IconData get _icon {
    switch (product.category) {
      case 'Makeup':
        return Icons.brush;
      case 'Hair Care':
        return Icons.spa;
      case 'Fragrance':
        return Icons.local_florist;
      default:
        return Icons.water_drop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.favorite_border,
                size: 18, color: AppColors.mutedText),
          ),
          Expanded(
            child: Center(
              child: Icon(_icon, size: 52, color: AppColors.sageGreen),
            ),
          ),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          Text(
            product.brand,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.mutedText),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.amber),
                  Text(' ${product.rating}',
                      style: GoogleFonts.poppins(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}