class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double rating;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.category,
  });
}

const sampleProducts = [
  Product(
    id: '1',
    name: 'Hydrating Serum',
    brand: 'The Ordinary',
    price: 24.0,
    rating: 4.3,
    category: 'Skincare',
  ),
  Product(
    id: '2',
    name: 'Moisturizing Cream',
    brand: 'CeraVe',
    price: 18.0,
    rating: 4.7,
    category: 'Skincare',
  ),
  Product(
    id: '3',
    name: 'Matte Lipstick',
    brand: 'Maybelline',
    price: 12.0,
    rating: 4.5,
    category: 'Makeup',
  ),
  Product(
    id: '4',
    name: 'Gentle Cleanser',
    brand: 'CeraVe',
    price: 15.0,
    rating: 4.6,
    category: 'Skincare',
  ),
  Product(
    id: '5',
    name: 'Argan Hair Oil',
    brand: 'Moroccanoil',
    price: 22.0,
    rating: 4.4,
    category: 'Hair Care',
  ),
  Product(
    id: '6',
    name: 'Floral Perfume',
    brand: 'Zara',
    price: 30.0,
    rating: 4.2,
    category: 'Fragrance',
  ),
];