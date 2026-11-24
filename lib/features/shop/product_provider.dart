import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';
import 'product_repository.dart';

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  static const _key = 'seller_custom_products';

  @override
  Future<List<Product>> build() async {
    return _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    final baseProducts = await ProductRepository().fetchProducts();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final custom = decoded
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          final ids = custom.map((p) => p.id).toSet();
          return [...custom, ...baseProducts.where((p) => !ids.contains(p.id))];
        }
      }
    } catch (_) {}
    return baseProducts;
  }

  Future<void> addProduct(Product product) async {
    final current = state.value ?? [];
    final updated = [product, ...current];
    state = AsyncData(updated);
    await _saveCustomProducts(updated);
  }

  Future<void> updateProduct(Product product) async {
    final current = state.value ?? [];
    final updated = current.map((p) => p.id == product.id ? product : p).toList();
    state = AsyncData(updated);
    await _saveCustomProducts(updated);
  }

  Future<void> deleteProduct(String id) async {
    final current = state.value ?? [];
    final updated = current.where((p) => p.id != id).toList();
    state = AsyncData(updated);
    await _saveCustomProducts(updated);
  }

  Future<void> resetToDefaults() async {
    state = const AsyncLoading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
    final defaults = await ProductRepository().fetchProducts();
    state = AsyncData(defaults);
  }

  Future<void> _saveCustomProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (_) {}
  }
}

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);
