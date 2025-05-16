import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final String image;
  final double rating;
  final List<String> categories;
  final bool isOpen;
  final String description;
  final String deliveryTime;
  final double deliveryFee;
  final double minimumOrder;
  final List<MenuItem> menu;

  Restaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.categories,
    required this.isOpen,
    required this.description,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minimumOrder,
    required this.menu,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      categories: List<String>.from(data['categories'] ?? []),
      isOpen: data['isOpen'] ?? false,
      description: data['description'] ?? '',
      deliveryTime: data['deliveryTime'] ?? '',
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      minimumOrder: (data['minimumOrder'] ?? 0.0).toDouble(),
      menu: (data['menu'] as List<dynamic>? ?? [])
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      rating: json['rating'].toDouble(),
      categories: List<String>.from(json['categories']),
      isOpen: json['isOpen'],
      description: json['description'],
      deliveryTime: json['deliveryTime'],
      deliveryFee: json['deliveryFee'].toDouble(),
      minimumOrder: json['minimumOrder'].toDouble(),
      menu: List<MenuItem>.from(
          json['menu'].map((item) => MenuItem.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'categories': categories,
      'isOpen': isOpen,
      'description': description,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'minimumOrder': minimumOrder,
      'menu': menu.map((item) => item.toJson()).toList(),
    };
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final List<String> categories;
  final bool isPopular;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.categories,
    required this.isPopular,
    required this.isAvailable,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      categories: List<String>.from(json['categories']),
      isPopular: json['isPopular'],
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'categories': categories,
      'isPopular': isPopular,
      'isAvailable': isAvailable,
    };
  }
}
