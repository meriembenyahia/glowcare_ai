import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
import '../../core/theme/widgets/product_image.dart';
import '../ai_advisor/ai_skin_analysis_screen.dart';
import '../auth/auth_provider.dart';
import '../auth/signup_screen.dart';
import '../auth/signup_prompt.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/product.dart';
import '../shop/product_details_screen.dart';
import '../shop/product_provider.dart';
import '../shop/shop_screen.dart';
import '../shop/wishlist_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _promptTimer;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _promptTimer = startSignupPromptTimer(context, ref);
  }

  @override
  void dispose() {
    _promptTimer?.cancel();
    _promptTimer = null;
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToShop([String category = 'All', String query = '']) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopScreen(
          initialCategory: category,
          initialQuery: query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(authProvider) == AuthStatus.guest;
    final productsAsync = ref.watch(productsProvider);
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الشريط العلوي: اللوغو + السلة + Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 34),
                      const SizedBox(width: 8),
                      Text(
                        'GlowCare AI',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_bag_outlined, color: colors.text),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.person_outline, color: colors.text),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        ),
                      ),
                      if (isGuest)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignupScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size(0, 34),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Sign Up', style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. البحث (Search Bar)
              TextField(
                controller: _searchController,
                onSubmitted: (q) => _navigateToShop('All', q),
                style: TextStyle(color: colors.text),
                decoration: InputDecoration(
                  hintText: 'Search for products, skincare...',
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search, color: colors.mutedText, size: 20),
                    onPressed: () => _navigateToShop('All', _searchController.text),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.tune, color: colors.mutedText, size: 20),
                    onPressed: () => _navigateToShop('All', _searchController.text),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  fillColor: colors.inputFill,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. البانر الرئيسي
              _banner(colors),
              const SizedBox(height: 14),

              // AI Skin Analysis Card
              _aiBanner(colors),
              const SizedBox(height: 16),

              // 4. الفئات الأربعة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Category(
                    icon: Icons.water_drop_outlined,
                    label: 'Skincare',
                    onTap: () => _navigateToShop('Skincare'),
                  ),
                  _Category(
                    icon: Icons.brush_outlined,
                    label: 'Makeup',
                    onTap: () => _navigateToShop('Makeup'),
                  ),
                  _Category(
                    icon: Icons.spa_outlined,
                    label: 'Hair Care',
                    onTap: () => _navigateToShop('Hair Care'),
                  ),
                  _Category(
                    icon: Icons.local_florist_outlined,
                    label: 'Fragrance',
                    onTap: () => _navigateToShop('Fragrance'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 5. قسم Best for You الأفقية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Best for You',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  InkWell(
                    onTap: () => _navigateToShop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'See All →',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // القائمة الأفقية للمنتجات
              SizedBox(
                height: 235,
                child: productsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                  error: (error, stack) => Center(
                    child: TextButton.icon(
                      onPressed: () => ref.invalidate(productsProvider),
                      icon: Icon(Icons.refresh, color: colors.primary),
                      label: Text(
                        'Tap to retry',
                        style: GoogleFonts.poppins(color: colors.primary),
                      ),
                    ),
                  ),
                  data: (products) => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: products[i]),
                        ),
                      ),
                      child: _ProductCard(product: products[i]),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 6. قسم المنتجات الشائعة العمودي
              Text(
                'Trending Products',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 10),

              productsAsync.when(
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
                data: (products) {
                  final list = products.reversed.toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length > 6 ? 6 : list.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = list[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(product: p),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ProductImage(path: p.image, size: 65),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colors.text,
                                      ),
                                    ),
                                    Text(
                                      '${p.brand} · ${p.category}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: colors.mutedText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${p.price.toStringAsFixed(0)} DA',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: colors.mutedText),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _banner(AppThemeColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.sageGreen.withValues(alpha: 0.35),
            AppColors.sageGreen.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Healthy Skin\nNatural Beauty',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover top skincare & makeup formulas',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: colors.mutedText,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _navigateToShop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Shop Now',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 100,
              height: 125,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const ProductImage(
                path: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&auto=format&fit=crop',
                size: 95,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiBanner(AppThemeColors colors) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AiSkinAnalysisScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: colors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Skin Consultation',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  Text(
                    'Take a 1-minute AI quiz to get custom skincare picks',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: colors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Category({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: colors.primary, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(wishlistProvider).contains(product.id);
    final colors = AppThemeColors.of(context);

    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => ref.read(wishlistProvider.notifier).toggle(product.id),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFav ? Colors.redAccent : colors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ProductImage(path: product.image, size: 95),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          Text(
            product.brand,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: colors.mutedText,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.price.toStringAsFixed(0)} DA',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.amber),
                  Text(
                    ' ${product.rating}',
                    style: GoogleFonts.poppins(
                        fontSize: 10, fontWeight: FontWeight.w500, color: colors.text),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
