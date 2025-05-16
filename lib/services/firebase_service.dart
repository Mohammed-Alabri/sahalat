import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sahalat/models/restaurant.dart';
import 'dart:typed_data';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication Methods
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Restaurant Methods
  static Future<List<Restaurant>> getRestaurants() async {
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Restaurant(
          id: doc.id,
          name: data['name'],
          image: data['image'],
          rating: data['rating'].toDouble(),
          categories: List<String>.from(data['categories']),
          isOpen: data['isOpen'],
          description: data['description'],
          deliveryTime: data['deliveryTime'],
          deliveryFee: data['deliveryFee'].toDouble(),
          minimumOrder: data['minimumOrder'].toDouble(),
          menu: (data['menu'] as List)
              .map((item) => MenuItem(
                    id: item['id'],
                    name: item['name'],
                    description: item['description'],
                    price: item['price'].toDouble(),
                    image: item['image'],
                    categories: List<String>.from(item['categories']),
                    isPopular: item['isPopular'],
                    isAvailable: item['isAvailable'],
                  ))
              .toList(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get restaurants: $e');
    }
  }

  static Future<Restaurant> getRestaurantById(String id) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(id).get();
      if (!doc.exists) {
        throw Exception('Restaurant not found');
      }

      final data = doc.data()!;
      return Restaurant(
        id: doc.id,
        name: data['name'],
        image: data['image'],
        rating: data['rating'].toDouble(),
        categories: List<String>.from(data['categories']),
        isOpen: data['isOpen'],
        description: data['description'],
        deliveryTime: data['deliveryTime'],
        deliveryFee: data['deliveryFee'].toDouble(),
        minimumOrder: data['minimumOrder'].toDouble(),
        menu: (data['menu'] as List)
            .map((item) => MenuItem(
                  id: item['id'],
                  name: item['name'],
                  description: item['description'],
                  price: item['price'].toDouble(),
                  image: item['image'],
                  categories: List<String>.from(item['categories']),
                  isPopular: item['isPopular'],
                  isAvailable: item['isAvailable'],
                ))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to get restaurant: $e');
    }
  }

  // Order Methods
  static Future<void> createOrder({
    required String userId,
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required double total,
    required String address,
    required String paymentMethod,
  }) async {
    try {
      await _firestore.collection('orders').add({
        'userId': userId,
        'restaurantId': restaurantId,
        'items': items,
        'total': total,
        'address': address,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Stream<QuerySnapshot> getOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Storage Methods
  static Future<String> uploadImage(String path, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
} 