class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String restaurantId;
  final List<String> categories;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.categories,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      restaurantId: json['restaurantId'],
      categories: List<String>.from(json['categories']),
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'restaurantId': restaurantId,
      'categories': categories,
      'isAvailable': isAvailable,
    };
  }
}
