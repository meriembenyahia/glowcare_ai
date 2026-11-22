import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shop/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  const CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product p) {
    final i = state.indexWhere((e) => e.product.id == p.id);
    if (i == -1) {
      state = [...state, CartItem(product: p)];
    } else {
      final updated = [...state];
      updated[i] = updated[i].copyWith(quantity: updated[i].quantity + 1);
      state = updated;
    }
  }

  void increase(String id) => _change(id, 1);
  void decrease(String id) => _change(id, -1);

  void _change(String id, int delta) {
    state = state
        .map((e) {
          if (e.product.id == id) {
            final newQty = e.quantity + delta;
            return newQty > 0 ? e.copyWith(quantity: newQty) : null;
          }
          return e;
        })
        .whereType<CartItem>()
        .toList();
  }

  void remove(String id) =>
      state = state.where((e) => e.product.id != id).toList();
  void clear() => state = [];
  double get subtotal =>
      state.fold(0, (sum, e) => sum + e.product.price * e.quantity);
}

final cartProvider =
NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);