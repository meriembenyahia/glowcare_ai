import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
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
  static const _sorts = ['Featured', 'Price ↑', 'Price ↓', 'Top rated'];
  late final TextEditingController _searchController;
  late String _selected;
  late String _query;
  String _sort = 'Featured';

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
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(size: 30),
                  const SizedBox(width: 8),
                  Text(
                    s.t('Shop'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // البحث
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(color: colors.text),
                decoration: InputDecoration(
                  hintText: s.t('Search products or brands...'),
                  prefixIcon: Icon(Icons.search, color: colors.mutedText, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  fillColor: colors.inputFill,
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
                      label: Text(s.t(cat)),
                      selected: active,
                      onSelected: (_) => setState(() => _selected = cat),
                      selectedColor: colors.primary,
                      backgroundColor: colors.cardBackground,
                      side: BorderSide.none,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? AppColors.white : colors.text,
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sorts.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final sort = _sorts[i];
                    final active = sort == _sort;
                    return ChoiceChip(
                      label: Text(s.t(sort)),
                      selected: active,
                      onSelected: (_) => setState(() => _sort = sort),
                      selectedColor: colors.primary.withValues(alpha: 0.3),
                      backgroundColor: colors.cardBackground,
                      side: BorderSide.none,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: colors.text,
                      ),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // الشبكة مع حالات التحميل والخطأ والبيانات
              Expanded(
                child: productsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.t('Failed to load products.\nCheck your internet connection.'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: colors.mutedText),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          onPressed: () => ref.invalidate(productsProvider),
                          child: Text(s.t('Retry')),
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

                    if (_sort == 'Price ↑') {
                      products.sort((a, b) => a.price.compareTo(b.price));
                    } else if (_sort == 'Price ↓') {
                      products.sort((a, b) => b.price.compareTo(a.price));
                    } else if (_sort == 'Top rated') {
                      products.sort((a, b) => b.rating.compareTo(a.rating));
                    }

                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          _selected == 'Favorites ❤️'
                              ? s.t('No favorite products yet ❤️')
                              : s.t('No products found'),
                          style: GoogleFonts.poppins(color: colors.mutedText),
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
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);

    return Container(
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
            alignment: AlignmentDirectional.topEnd,
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
              child: ProductImage(path: product.image, size: 100),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          Text(
            product.brand,
            style: GoogleFonts.poppins(fontSize: 10, color: colors.mutedText),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.money(product.price),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.amber),
                  Text(' ${product.rating}',
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w500, color: colors.text)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
