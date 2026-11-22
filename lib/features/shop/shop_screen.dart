import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/product_image.dart';
import 'product.dart';
import 'product_details_screen.dart';
import 'product_provider.dart';
import 'wishlist_provider.dart';

class ShopScreen extends ConsumerStatefulWidget {
  final String initialCategory;
  final String initialQuery;
  const ShopScreen({
    super.key,
    this.initialCategory = 'All',
    this.initialQuery = '',
  });

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  static const _categories = ['All', 'Favorites ❤️', 'Skincare', 'Makeup', 'Hair Care', 'Fragrance'];
  late final TextEditingController _searchController;
  late String _selected;
  late String _query;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory;
    _query = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      setState(() => _selected = widget.initialCategory);
    }
    if (oldWidget.initialQuery != widget.initialQuery) {
      setState(() {
        _query = widget.initialQuery;
        _searchController.text = widget.initialQuery;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),

              // البحث
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search products or brands...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.mutedText, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  fillColor: AppColors.white,
                  filled: true,
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
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
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
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? AppColors.white : AppColors.darkText,
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // الشبكة مع حالات التحميل والخطأ والبيانات
              Expanded(
                child: productsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.deepGreen),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load products.\nCheck your internet connection.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepGreen,
                            foregroundColor: AppColors.white,
                          ),
                          onPressed: () => ref.invalidate(productsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (allProducts) {
                    final wishlist = ref.watch(wishlistProvider);
                    final products = allProducts.where((p) {
                      final matchCat = _selected == 'All' ||
                          (_selected == 'Favorites ❤️'
                              ? wishlist.contains(p.id)
                              : p.category == _selected);
                      final q = _query.toLowerCase();
                      final matchQuery = q.isEmpty ||
                          p.name.toLowerCase().contains(q) ||
                          p.brand.toLowerCase().contains(q);
                      return matchCat && matchQuery;
                    }).toList();

                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          _selected == 'Favorites ❤️'
                              ? 'No favorite products yet ❤️'
                              : 'No products found',
                          style: GoogleFonts.poppins(color: AppColors.mutedText),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(product: products[i]),
                          ),
                        ),
                        child: _ShopCard(product: products[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopCard extends ConsumerWidget {
  final Product product;
  const _ShopCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(wishlistProvider).contains(product.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
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
                color: isFav ? Colors.redAccent : AppColors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ProductImage(path: product.image, size: 100),
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
              color: AppColors.darkText,
            ),
          ),
          Text(
            product.brand,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.mutedText),
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
                  color: AppColors.deepGreen,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.amber),
                  Text(' ${product.rating}',
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
