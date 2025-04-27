import '../models/restaurant.dart';

class RestaurantService {
  static final List<Restaurant> _restaurants = [
    Restaurant(
      id: '1',
      name: 'Al Mandoos Restaurant',
      image: 'assets/images/vendors/almandoos.jpg',
      rating: 4.8,
      categories: ['Omani', 'Traditional'],
      isOpen: true,
      description: 'Authentic Omani cuisine in a traditional setting',
      deliveryTime: '30-45 min',
      deliveryFee: 1.5,
      minimumOrder: 5.0,
      menu: [
        MenuItem(
          id: '1',
          name: 'Shuwa',
          description: 'Traditional Omani slow-cooked lamb',
          price: 12.99,
          categories: ['Main Course', 'Traditional'],
          isPopular: true,
          isAvailable: true,
        ),
        MenuItem(
          id: '2',
          name: 'Chicken Majboos',
          description: 'Spiced rice with tender chicken',
          price: 8.99,
          categories: ['Main Course', 'Rice'],
          isPopular: true,
          isAvailable: true,
        ),
      ],
    ),
    Restaurant(
      id: '2',
      name: 'Automatic Restaurant',
      image: 'assets/images/vendors/automatic.jpg',
      rating: 4.5,
      categories: ['Lebanese', 'Grills'],
      isOpen: true,
      description: 'Famous Lebanese grills and mezze',
      deliveryTime: '25-40 min',
      deliveryFee: 2.0,
      minimumOrder: 7.0,
      menu: [
        MenuItem(
          id: '1',
          name: 'Mixed Grill',
          description: 'Assortment of grilled meats',
          price: 15.99,
          categories: ['Main Course', 'Grills'],
          isPopular: true,
          isAvailable: true,
        ),
        MenuItem(
          id: '2',
          name: 'Hummus',
          description: 'Creamy chickpea dip with olive oil',
          price: 3.99,
          categories: ['Appetizer', 'Vegetarian'],
          isPopular: true,
          isAvailable: true,
        ),
      ],
    ),
    Restaurant(
      id: '3',
      name: 'Turkish House',
      image: 'assets/images/vendors/turkish.jpg',
      rating: 4.7,
      categories: ['Turkish', 'Grills'],
      isOpen: true,
      description: 'Authentic Turkish cuisine and kebabs',
      deliveryTime: '35-50 min',
      deliveryFee: 1.8,
      minimumOrder: 6.0,
      menu: [
        MenuItem(
          id: '1',
          name: 'Iskender Kebab',
          description: 'Sliced lamb over pita with tomato sauce and yogurt',
          price: 13.99,
          categories: ['Main Course', 'Grills'],
          isPopular: true,
          isAvailable: true,
        ),
        MenuItem(
          id: '2',
          name: 'Pide',
          description: 'Turkish pizza with various toppings',
          price: 7.99,
          categories: ['Main Course', 'Bread'],
          isPopular: false,
          isAvailable: true,
        ),
      ],
    ),
  ];

  static List<Restaurant> getAllRestaurants() {
    return List.from(_restaurants);
  }

  static List<Restaurant> getPopularRestaurants() {
    return _restaurants
        .where((restaurant) => restaurant.rating >= 4.5)
        .toList();
  }

  static List<Restaurant> getRestaurantsByCategory(String category) {
    return _restaurants
        .where((restaurant) => restaurant.categories
            .map((e) => e.toLowerCase())
            .contains(category.toLowerCase()))
        .toList();
  }

  static Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<MenuItem> getPopularMenuItems() {
    List<MenuItem> popularItems = [];
    for (var restaurant in _restaurants) {
      popularItems.addAll(
        restaurant.menu.where((item) => item.isPopular),
      );
    }
    return popularItems;
  }

  static List<String> getAllCategories() {
    Set<String> categories = {};
    for (var restaurant in _restaurants) {
      categories.addAll(restaurant.categories);
    }
    return categories.toList()..sort();
  }
}
