import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/signup_prompt.dart';
import '../cart/cart_screen.dart';
import '../shop/product.dart';
import '../shop/product_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _promptTimer;

  @override
  void initState() {
    super.initState();
    _promptTimer = startSignupPromptTimer(context, ref);
  }

  @override
  void dispose() {
    _promptTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(authProvider) == AuthStatus.guest;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الفوق: اللوغو + الاسم + السلة + Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 36),
                      const SizedBox(width: 8),
                      Text(
                        'GlowCare AI',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined,
                            color: AppColors.darkText),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CartScreen()),
                        ),
                      ),
                      if (isGuest)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 38),
                            padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text('Sign Up'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. البحث
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for products, skincare...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.mutedText, size: 20),
                  suffixIcon: const Icon(Icons.tune,
                      color: AppColors.mutedText, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. البانر
              _banner(),
              const SizedBox(height: 20),

              // 4. الفئات
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Category(icon: Icons.water_drop_outlined, label: 'Skincare'),
                  _Category(icon: Icons.brush_outlined, label: 'Makeup'),
                  _Category(icon: Icons.spa_outlined, label: 'Hair Care'),
                  _Category(
                      icon: Icons.local_florist_outlined, label: 'Fragrance'),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Best for You
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Best for You',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    'See All →',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sampleProducts.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(width: 12),
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsScreen(product: sampleProducts[i]),
                      ),
                    ),
                    child: _ProductCard(product: sampleProducts[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _banner() {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sageGreen.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Healthy Skin\nNatural Beauty',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Discover the best skincare\n& makeup for your skin',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Text('Shop Now', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Category({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: AppColors.deepGreen),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
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
              child: Icon(
                product.category == 'Makeup' ? Icons.brush : Icons.water_drop,
                size: 48,
                color: AppColors.sageGreen,
              ),
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
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.mutedText,
            ),
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
                  Text(
                    ' ${product.rating}',
                    style: GoogleFonts.poppins(fontSize: 10),
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