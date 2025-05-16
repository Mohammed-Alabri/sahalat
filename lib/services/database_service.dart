import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static final CollectionReference _usersCollection = _firestore.collection('users');
  static final CollectionReference _productsCollection = _firestore.collection('products');
  static final CollectionReference _ordersCollection = _firestore.collection('orders');
  static final CollectionReference _restaurantsCollection = _firestore.collection('restaurants');

  // Initialize database with sample data if empty
  static Future<void> initializeDatabase() async {
    try {
      // Check and initialize all required collections
      final collections = [
        'restaurants',
        'categories',
        'featured_items',
        'settings'
      ];

      for (final collectionName in collections) {
        print('Checking collection: $collectionName');
        final collection = _firestore.collection(collectionName);
        final snapshot = await collection.limit(1).get();
        
        if (snapshot.docs.isEmpty) {
          print('Initializing $collectionName collection with sample data...');
          
          switch (collectionName) {
            case 'restaurants':
              await _initializeRestaurants();
              break;
            case 'categories':
              await _initializeCategories();
              break;
            case 'featured_items':
              await _initializeFeaturedItems();
              break;
            case 'settings':
              await _initializeSettings();
              break;
          }
          print('Successfully initialized $collectionName collection');
        } else {
          print('Collection $collectionName already has data, skipping initialization');
        }
      }
      
      print('Database initialization completed successfully!');
    } catch (e) {
      print('Error initializing database: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  static Future<void> _initializeRestaurants() async {
    final restaurants = [
      {
        'name': 'Burger House',
        'image': 'https://picsum.photos/400/300',
        'rating': 4.5,
        'categories': ['Fast Food', 'Burgers'],
        'isOpen': true,
        'description': 'Best burgers in town!',
        'deliveryTime': '30-45 min',
        'deliveryFee': 2.99,
        'minimumOrder': 10.0,
        'menu': [
          {
            'id': '1',
            'name': 'Classic Burger',
            'description': 'Juicy beef patty with fresh vegetables',
            'price': 8.99,
            'image': 'https://picsum.photos/200',
            'categories': ['Burgers'],
            'isPopular': true,
            'isAvailable': true,
          },
          {
            'id': '2',
            'name': 'Cheese Fries',
            'description': 'Crispy fries with melted cheese',
            'price': 4.99,
            'image': 'https://picsum.photos/200',
            'categories': ['Sides'],
            'isPopular': true,
            'isAvailable': true,
          }
        ]
      },
      {
        'name': 'Pizza Paradise',
        'image': 'https://picsum.photos/400/300',
        'rating': 4.7,
        'categories': ['Pizza', 'Italian'],
        'isOpen': true,
        'description': 'Authentic Italian pizzas',
        'deliveryTime': '40-55 min',
        'deliveryFee': 3.99,
        'minimumOrder': 15.0,
        'menu': [
          {
            'id': '1',
            'name': 'Margherita Pizza',
            'description': 'Classic tomato and mozzarella',
            'price': 12.99,
            'image': 'https://picsum.photos/200',
            'categories': ['Pizza'],
            'isPopular': true,
            'isAvailable': true,
          }
        ]
      }
    ];

    for (final restaurant in restaurants) {
      final docRef = await _firestore.collection('restaurants').add({
        ...restaurant,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add menu items as a subcollection
      if (restaurant['menu'] != null) {
        for (final menuItem in restaurant['menu'] as List) {
          await _firestore
              .collection('restaurants')
              .doc(docRef.id)
              .collection('menu')
              .add({
            ...menuItem,
            'restaurantId': docRef.id,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  static Future<void> _initializeCategories() async {
    final categories = [
      {
        'name': 'Fast Food',
        'icon': '🍔',
        'imageUrl': 'https://picsum.photos/200',
        'isActive': true,
        'sortOrder': 1,
      },
      {
        'name': 'Pizza',
        'icon': '🍕',
        'imageUrl': 'https://picsum.photos/200',
        'isActive': true,
        'sortOrder': 2,
      },
      {
        'name': 'Sushi',
        'icon': '🍱',
        'imageUrl': 'https://picsum.photos/200',
        'isActive': true,
        'sortOrder': 3,
      },
      {
        'name': 'Italian',
        'icon': '🍝',
        'imageUrl': 'https://picsum.photos/200',
        'isActive': true,
      },
      {
        'name': 'Desserts',
        'icon': '🍰',
        'imageUrl': 'https://picsum.photos/200',
        'isActive': true,
      }
    ];

    for (final category in categories) {
      await _firestore.collection('categories').add({
        ...category,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> _initializeFeaturedItems() async {
    final featuredItems = [
      {
        'title': 'Special Offer',
        'description': 'Get 20% off on your first order',
        'imageUrl': 'https://picsum.photos/400/200',
        'type': 'promotion',
        'priority': 1,
        'validUntil': DateTime.now().add(const Duration(days: 7)),
      },
      {
        'title': 'New Restaurant',
        'description': 'Try our latest partner restaurant',
        'imageUrl': 'https://picsum.photos/400/200',
        'type': 'restaurant',
        'priority': 2,
      },
      {
        'title': 'Free Delivery',
        'description': 'Free delivery on orders above \$30',
        'imageUrl': 'https://picsum.photos/400/200',
        'type': 'promotion',
        'priority': 3,
        'validUntil': DateTime.now().add(const Duration(days: 14)),
      }
    ];

    for (final item in featuredItems) {
      await _firestore.collection('featured_items').add({
        ...item,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> _initializeSettings() async {
    await _firestore.collection('settings').doc('app').set({
      'maintenance_mode': false,
      'min_app_version': '1.0.0',
      'recommended_app_version': '1.0.0',
      'support_phone': '+1234567890',
      'support_email': 'support@sahalat.com',
      'delivery_fee_base': 2.0,
      'delivery_fee_per_km': 0.5,
      'min_order_amount': 10.0,
      'max_order_distance': 10.0,
      'currency': 'USD',
      'currency_symbol': '\$',
      'app_name': 'Sahalat',
      'company_name': 'Sahalat Food Delivery',
      'social_media': {
        'facebook': 'https://facebook.com/sahalat',
        'instagram': 'https://instagram.com/sahalat',
        'twitter': 'https://twitter.com/sahalat'
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Users
  static Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    await _usersCollection.doc(uid).set({
      ...userData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    await _usersCollection.doc(uid).update({
      ...userData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Products
  static Future<String> createProduct(Map<String, dynamic> productData) async {
    final docRef = await _productsCollection.add({
      ...productData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    await _productsCollection.doc(productId).update({
      ...productData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }

  static Stream<QuerySnapshot> getProducts({
    String? restaurantId,
    String? category,
    String? searchQuery,
  }) {
    Query query = _productsCollection;
    
    if (restaurantId != null) {
      query = query.where('restaurantId', isEqualTo: restaurantId);
    }
    
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
                  .where('name', isLessThan: searchQuery + 'z');
    }
    
    return query.snapshots();
  }

  // Orders
  static Future<String> createOrder(Map<String, dynamic> orderData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    final docRef = await _ordersCollection.add({
      ...orderData,
      'userId': user.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    await _ordersCollection.doc(orderId).update({
      ...orderData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Restaurants
  static Future<String> createRestaurant(Map<String, dynamic> restaurantData) async {
    final docRef = await _restaurantsCollection.add({
      ...restaurantData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> updateRestaurant(String restaurantId, Map<String, dynamic> restaurantData) async {
    await _restaurantsCollection.doc(restaurantId).update({
      ...restaurantData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteRestaurant(String restaurantId) async {
    await _restaurantsCollection.doc(restaurantId).delete();
  }

  static Stream<QuerySnapshot> getRestaurants({String? searchQuery, String? category}) {
    Query query = _restaurantsCollection;
    
    if (category != null) {
      query = query.where('categories', arrayContains: category);
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
                  .where('name', isLessThan: searchQuery + 'z');
    }
    
    return query.snapshots();
  }

  // Search functionality
  static Future<List<QuerySnapshot>> searchAll(String query) async {
    final results = await Future.wait([
      _productsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get(),
      _restaurantsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get(),
    ]);
    return results;
  }

  // Update user profile
  static Future<void> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (name != null) {
        updates['name'] = name;
        await user.updateDisplayName(name);
      }
      if (phone != null) updates['phone'] = phone;

      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
} 