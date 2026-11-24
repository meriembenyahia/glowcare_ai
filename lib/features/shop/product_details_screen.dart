import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_bar_title.dart';
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
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);
    final ingredientsText = product.ingredients.isNotEmpty
        ? product.ingredients.join(', ')
        : s.t('Water, Glycerin, Niacinamide, Hyaluronic Acid, Ceramides 1, 3, 6-II, Centella Asiatica Extract.');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          centerTitle: true,
          title: AppBarTitle(
            text: s.t('Product Details'),
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          iconTheme: IconThemeData(color: colors.text),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : colors.text,
              ),
              tooltip: s.t('Wishlist'),
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
                      // 1. حاوية صورة المنتج الكبيرة
                      Container(
                        height: 220,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
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

                      // نقاط مؤشر الصور
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
                                    ? colors.primary
                                    : colors.mutedText.withValues(alpha: 0.3),
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
                                    color: colors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${product.brand}  ✦  ${s.t(product.category)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: colors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.mutedText.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              s.t('50 ml'),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colors.mutedText,
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
                            s.tf('{rating} ({count} reviews)', {
                              'rating': '${product.rating}',
                              'count': '2.4k',
                            }),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: colors.mutedText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 4. السعر بالدينار DA
                      Text(
                        s.money(product.price),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. التبويبات الثلاثة
                      TabBar(
                        labelColor: colors.primary,
                        unselectedLabelColor: colors.mutedText,
                        indicatorColor: colors.primary,
                        indicatorWeight: 2.5,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [
                          Tab(text: s.t('Details')),
                          Tab(text: s.t('Ingredients')),
                          Tab(text: s.t('Reviews')),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // محتوى التبويبات
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
                                    children: [
                                      _FeaturePill(icon: Icons.check_circle_outline, label: s.t('Fragrance Free')),
                                      const SizedBox(width: 8),
                                      _FeaturePill(icon: Icons.verified_user_outlined, label: s.t('Dermatologist Tested')),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    s.productDescription(
                                      product.id,
                                      product.description.isNotEmpty
                                          ? product.description
                                          : s.t(
                                              'Provides 24-hour hydration and helps restore the protective skin barrier with essential ceramides & hyaluronic acid.'),
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      height: 1.6,
                                      color: colors.text,
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
                                  color: colors.text,
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
                                        fontWeight: FontWeight.w600,
                                        color: colors.text),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.t('"Excellent product for my daily skincare routine! Highly recommended for sensitive skin."'),
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: colors.mutedText),
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
                  color: colors.cardBackground,
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
                          content: Text(s.tf('{name} added to cart!', {'name': product.name})),
                          backgroundColor: colors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                    label: Text(
                      s.t('Add to Cart'),
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
    final colors = AppThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
