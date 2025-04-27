class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String restaurantId;
  final String restaurantName;
  final String image;
  final List<String> categories;
  final bool isAvailable;
  final int preparationTime;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.restaurantId,
    required this.restaurantName,
    required this.image,
    required this.categories,
    this.isAvailable = true,
    this.preparationTime = 15,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      image: json['image'],
      categories: List<String>.from(json['categories']),
      isAvailable: json['isAvailable'],
      preparationTime: json['preparationTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'image': image,
      'categories': categories,
      'isAvailable': isAvailable,
      'preparationTime': preparationTime,
    };
  }
}
