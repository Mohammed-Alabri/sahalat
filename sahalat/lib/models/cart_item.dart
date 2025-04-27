class CartItem {
  final String id;
  final String name;
  final String restaurantId;
  final String restaurantName;
  final double price;
  final int quantity;
  final String? image;
  final String? note;

  CartItem({
    required this.id,
    required this.name,
    required this.restaurantId,
    required this.restaurantName,
    required this.price,
    required this.quantity,
    this.image,
    this.note,
  });

  double get total => price * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    String? restaurantId,
    String? restaurantName,
    double? price,
    int? quantity,
    String? image,
    String? note,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      note: note ?? this.note,
    );
  }

  bool isSameRestaurant(CartItem other) {
    return restaurantId == other.restaurantId;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'price': price,
      'quantity': quantity,
      'image': image,
      'note': note,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      image: json['image'] as String?,
      note: json['note'] as String?,
    );
  }
}
