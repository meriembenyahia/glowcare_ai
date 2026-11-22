import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/product_image.dart';
import '../cart/cart_provider.dart';
import 'product.dart';
import 'wishlist_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isFavorite = ref.watch(wishlistProvider).contains(product.id);
    final ingredientsText = product.ingredients.isNotEmpty
        ? product.ingredients.join(', ')
        : 'Water, Glycerin, Niacinamide, Hyaluronic Acid, Ceramides 1, 3, 6-II, Centella Asiatica Extract.';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Product Details',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.darkText),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : AppColors.darkText,
              ),
              onPressed: () => ref.read(wishlistProvider.notifier).toggle(product.id),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. حاوية صورة المنتج الكبيرة الفوق مطابقة للموكاب
                      Container(
                        height: 220,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ProductImage(
                            path: product.image,
                            size: 170,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // نقاط مؤشر الصور (Carousel Indicator Dots)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isActive = index == _selectedImageIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedImageIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 7,
                              width: isActive ? 18 : 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.deepGreen
                                    : AppColors.mutedText.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // 2. اسم المنتج و الماركة و الحجم (50 ml)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${product.brand}  ✦  ${product.category}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.mutedText.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              '50 ml',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 3. النجوم والتقييم
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const Icon(Icons.star_half, size: 16, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(
                            '${product.rating} (2.4k reviews)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 4. السعر بالدينار DA
                      Text(
                        '${product.price.toStringAsFixed(0)} DA',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepGreen,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. التبويبات الثلاثة (Details, Ingredients, Reviews)
                      TabBar(
                        labelColor: AppColors.deepGreen,
                        unselectedLabelColor: AppColors.mutedText,
                        indicatorColor: AppColors.deepGreen,
                        indicatorWeight: 2.5,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: 'Details'),
                          Tab(text: 'Ingredients'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // محتوى التبويبات مع مميزات المنتج (Pills)
                      SizedBox(
                        height: 160,
                        child: TabBarView(
                          children: [
                            // Details Tab
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      _FeaturePill(icon: Icons.check_circle_outline, label: 'Fragrance Free'),
                                      SizedBox(width: 8),
                                      _FeaturePill(icon: Icons.verified_user_outlined, label: 'Dermatologist Tested'),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    product.description.isNotEmpty
                                        ? product.description
                                        : 'Provides 24-hour hydration and helps restore the protective skin barrier with essential ceramides & hyaluronic acid.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      height: 1.6,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Ingredients Tab
                            SingleChildScrollView(
                              child: Text(
                                ingredientsText,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  height: 1.6,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),

                            // Reviews Tab
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⭐⭐⭐⭐⭐ (4.8/5)',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"Excellent product for my daily skincare routine! Highly recommended for sensitive skin."',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.mutedText),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 6. الزر السفل الإضافة للسلة Add to Cart
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(cartProvider.notifier).add(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart!'),
                          backgroundColor: AppColors.deepGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                    label: Text(
                      'Add to Cart',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.sageGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.deepGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.deepGreen,
            ),
          ),
        ],
      ),
    );
  }
}
