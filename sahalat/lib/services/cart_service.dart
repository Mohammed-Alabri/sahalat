import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahalat/models/cart_item.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // In-memory storage for cart items (replace with actual storage in production)
  static final List<CartItem> _cartItems = [];

  // Get all cart items
  static Future<List<CartItem>> getCartItems() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _cartItems;
  }

  // Add item to cart
  static Future<void> addToCart(CartItem item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final existingIndex = _cartItems.indexWhere((i) => i.id == item.id);
    if (existingIndex != -1) {
      _cartItems[existingIndex] = item;
    } else {
      _cartItems.add(item);
    }
  }

  // Update cart item
  static Future<void> updateCartItem(CartItem item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _cartItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _cartItems[index] = item;
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _cartItems.removeWhere((item) => item.id == itemId);
  }

  // Clear cart
  static Future<void> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _cartItems.clear();
  }

  // Get cart total
  static Future<double> getCartTotal() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _cartItems.fold<double>(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Check if cart has items from multiple restaurants
  static Future<bool> hasMultipleRestaurants() async {
    if (_cartItems.isEmpty) return false;
    final firstRestaurantId = _cartItems.first.restaurantId;
    return _cartItems.any((item) => item.restaurantId != firstRestaurantId);
  }
}
