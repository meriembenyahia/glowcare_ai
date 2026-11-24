class Product {
  final String id;
  final String name;
  final String brand;
  final double price; // بالدينار DA
  final double rating;
  final String category;
  final String image;
  final String description;
  final List<String> ingredients;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.category,
    required this.image,
    this.description = '',
    this.ingredients = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'price': price,
    'rating': rating,
    'category': category,
    'image': image,
    'description': description,
    'ingredients': ingredients,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawCat = (json['category'] ?? '').toString();
    String mappedCategory = rawCat;
    if (rawCat.toLowerCase() == 'beauty') {
      mappedCategory = 'Makeup';
    } else if (rawCat.toLowerCase() == 'fragrances') {
      mappedCategory = 'Fragrance';
    } else if (mappedCategory.isEmpty) {
      mappedCategory = 'Skincare';
    }

    final double priceVal = (json['price'] as num?)?.toDouble() ?? 0.0;
    final List<String> ings = [];
    final rawIng = json['ingredients'] ?? json['tags'];
    if (rawIng is List) {
      for (final i in rawIng) {
        if (i != null) ings.add(i.toString());
      }
    }

    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      brand: (json['brand'] ?? 'GlowCare').toString(),
      price: priceVal,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      category: mappedCategory,
      image: (json['image'] ?? json['thumbnail'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ingredients: ings,
    );
  }
}