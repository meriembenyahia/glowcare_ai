import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product.dart';
import 'product_repository.dart';

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ProductRepository().fetchProducts();
});