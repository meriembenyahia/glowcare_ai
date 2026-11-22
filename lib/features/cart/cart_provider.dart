import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shop/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  const CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'product': {
          'id': product.id,
          'name': product.name,
          'brand': product.brand,
          'price': product.price,
          'rating': product.rating,
          'category': product.category,
          'image': product.image,
          'description': product.description,
          'ingredients': product.ingredients,
        },
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final raw = json['product'];
    final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final ingredients = <String>[];
    final rawIngredients = map['ingredients'];
    if (rawIngredients is List) {
      for (final item in rawIngredients) {
        if (item != null) ingredients.add(item.toString());
      }
    }
    return CartItem(
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      product: Product(
        id: (map['id'] ?? '').toString(),
        name: (map['name'] ?? 'Product').toString(),
        brand: (map['brand'] ?? 'GlowCare').toString(),
        price: (map['price'] as num?)?.toDouble() ?? 0,
        rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
        category: (map['category'] ?? 'Skincare').toString(),
        image: (map['image'] ?? '').toString(),
        description: (map['description'] ?? '').toString(),
        ingredients: ingredients,
      ),
    );
  }
}

class CartNotifier extends Notifier<List<CartItem>> {
  static const _key = 'cart_json';

  @override
  List<CartItem> build() {
    _restore();
    return [];
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      // لا نمسح منتجات أضافها المستخدم قبل انتهاء التحميل
      final saved = [
        for (final item in decoded)
          if (item is Map) CartItem.fromJson(Map<String, dynamic>.from(item)),
      ];
      final currentIds = state.map((item) => item.product.id).toSet();
      state = [
        ...state,
        ...saved.where((item) => !currentIds.contains(item.product.id)),
      ];
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final item in state) item.toJson()]),
    );
  }

  void add(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      state = [...state, CartItem(product: product)];
    } else {
      final updated = [...state];
      updated[index] =
          updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = updated;
    }
    _persist();
  }

  void increase(String id) => _change(id, 1);
  void decrease(String id) => _change(id, -1);

  void _change(String id, int delta) {
    state = state
        .map((item) {
          if (item.product.id != id) return item;
          final next = item.quantity + delta;
          return next > 0 ? item.copyWith(quantity: next) : null;
        })
        .whereType<CartItem>()
        .toList();
    _persist();
  }

  void remove(String id) {
    state = state.where((item) => item.product.id != id).toList();
    _persist();
  }

  void clear() {
    state = [];
    _persist();
  }

  double get subtotal =>
      state.fold(0, (sum, item) => sum + item.product.price * item.quantity);
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
