import 'package:sahalat/models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static const String _cartKey = 'cart_items';
  static List<CartItem>? _cartItems;

  // Load cart items from storage
  static Future<void> _loadCartItems() async {
    if (_cartItems != null) return;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _cartItems = [];
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      _cartItems = snapshot.docs
          .map((doc) => CartItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      _cartItems = [];
      throw Exception('Failed to load cart items: $e');
    }
  }

  // Save cart items to storage
  static Future<void> _saveCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final batch = _firestore.batch();
      for (var item in _cartItems!) {
        batch.set(_firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(item.id), item.toJson());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save cart items: $e');
    }
  }

  // Get all cart items
  static Future<List<CartItem>> getCartItems() async {
    try {
      await _loadCartItems();
      return List.unmodifiable(_cartItems!);
    } catch (e) {
      throw Exception('Failed to get cart items: $e');
    }
  }

  // Add item to cart
  static Future<void> addToCart(CartItem item) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.id)
          .set(item.toJson());
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Update cart item
  static Future<void> updateCartItem(CartItem item) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.id)
          .update(item.toJson());
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(String itemId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(itemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Clear cart
  static Future<void> clearCart() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Get cart total
  static Future<double> getCartTotal() async {
    try {
      await _loadCartItems();
      return _cartItems!.fold<double>(
          0.0, (sum, item) => sum + (item.price * item.quantity));
    } catch (e) {
      throw Exception('Failed to calculate cart total: $e');
    }
  }

  // Check if cart has items from multiple restaurants
  static Future<bool> hasMultipleRestaurants() async {
    try {
      await _loadCartItems();
      if (_cartItems!.isEmpty) return false;
      final firstRestaurantId = _cartItems!.first.restaurantId;
      return _cartItems!.any((item) => item.restaurantId != firstRestaurantId);
    } catch (e) {
      throw Exception('Failed to check restaurants: $e');
    }
  }

  static Future<List<CartItem>> getSavedItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_items')
          .get();

      return snapshot.docs
          .map((doc) => CartItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load saved items: $e');
    }
  }

  static Future<void> moveToSavedItems(CartItem item) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Start a batch write
      final batch = _firestore.batch();

      // Remove from cart
      final cartRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.id);
      batch.delete(cartRef);

      // Add to saved items
      final savedRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_items')
          .doc(item.id);
      batch.set(savedRef, item.toJson());

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save item for later: $e');
    }
  }

  static Future<void> moveToCart(CartItem item) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Start a batch write
      final batch = _firestore.batch();

      // Remove from saved items
      final savedRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_items')
          .doc(item.id);
      batch.delete(savedRef);

      // Add to cart
      final cartRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.id);
      batch.set(cartRef, item.toJson());

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to move item to cart: $e');
    }
  }

  static Future<String> getRestaurantDeliveryTime(String restaurantId) async {
    try {
      final doc = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      if (!doc.exists) {
        throw Exception('Restaurant not found');
      }

      return doc.data()?['deliveryTime'] ?? '30-45 min';
    } catch (e) {
      return '30-45 min'; // Default fallback
    }
  }
}
