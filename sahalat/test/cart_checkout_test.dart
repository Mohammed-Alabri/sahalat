import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahalat/pages/cart_page.dart';
import 'package:sahalat/pages/checkout_page.dart';
import 'package:sahalat/models/cart_item.dart';
import 'package:sahalat/services/cart_service.dart';

// Mock implementation of CartService for testing
class MockCartService extends CartService {
  static List<CartItem> _mockCartItems = [];

  @override
  static Future<List<CartItem>> getCartItems() async {
    return _mockCartItems;
  }

  @override
  static Future<void> clearCart() async {
    _mockCartItems = [];
  }

  @override
  static Future<void> removeFromCart(String id) async {
    _mockCartItems.removeWhere((item) => item.id == id);
  }

  @override
  static Future<void> updateCartItem(CartItem item) async {
    final index = _mockCartItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _mockCartItems[index] = item;
    }
  }

  static void resetMockItems(List<CartItem> items) {
    _mockCartItems = List.from(items);
  }
}

void main() {
  group('Cart Page Tests', () {
    late List<CartItem> initialCartItems;

    setUp(() {
      // Reset mock cart items before each test
      initialCartItems = [
        CartItem(
          id: '1',
          name: 'Mixed Grill',
          restaurantId: '1',
          restaurantName: 'Automatic Restaurant',
          price: 15.99,
          quantity: 1,
        ),
        CartItem(
          id: '2',
          name: 'Chicken Majboos',
          restaurantId: '2',
          restaurantName: 'Al Mandoos Restaurant',
          price: 8.99,
          quantity: 3,
        ),
      ];
      MockCartService.resetMockItems(initialCartItems);
    });

    testWidgets('Shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartPage(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Shows empty state when cart is empty',
        (WidgetTester tester) async {
      MockCartService.resetMockItems([]);

      await tester.pumpWidget(
        const MaterialApp(
          home: CartPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Browse Restaurants'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('Shows cart items when cart is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify items are displayed
      expect(find.text('Mixed Grill'), findsOneWidget);
      expect(find.text('Chicken Majboos'), findsOneWidget);
      expect(find.text('Proceed to Checkout'), findsOneWidget);

      // Verify restaurant names
      expect(find.text('Automatic Restaurant'), findsOneWidget);
      expect(find.text('Al Mandoos Restaurant'), findsOneWidget);

      // Verify prices
      expect(find.text('\$15.99'), findsOneWidget);
      expect(find.text('\$8.99'), findsOneWidget);
    });

    testWidgets('Can update item quantity', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the add button for the first item
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      final items = await MockCartService.getCartItems();
      expect(items[0].quantity, 2);

      // Find and tap the remove button
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();

      final updatedItems = await MockCartService.getCartItems();
      expect(updatedItems[0].quantity, 1);
    });

    testWidgets('Shows warning for multiple restaurants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify warning message is shown
      expect(
        find.text(
            'You have items from multiple restaurants. Please order from one restaurant at a time.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('Can clear cart', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap clear cart button
      await tester.tap(find.text('Clear Cart'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Are you sure you want to clear your cart?'),
          findsOneWidget);

      // Confirm clear cart
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Verify cart is empty
      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('Can remove individual item', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap remove button (by reducing quantity to 0)
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Remove Mixed Grill from cart?'), findsOneWidget);

      // Confirm removal
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Verify item was removed
      expect(find.text('Mixed Grill'), findsNothing);
      final items = await MockCartService.getCartItems();
      expect(items.length, 1);
    });

    testWidgets('Shows correct total calculations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Calculate expected values
      final subtotal = 15.99 + (8.99 * 3);
      final tax = subtotal * 0.15;
      final deliveryFee = 5.0;
      final total = subtotal + tax + deliveryFee;

      // Verify totals are displayed correctly
      expect(find.text('\$${subtotal.toStringAsFixed(2)}'), findsOneWidget);
      expect(find.text('\$${tax.toStringAsFixed(2)}'), findsOneWidget);
      expect(find.text('\$${deliveryFee.toStringAsFixed(2)}'), findsOneWidget);
      expect(find.text('\$${total.toStringAsFixed(2)}'), findsOneWidget);
    });
  });

  group('Checkout Page Tests', () {
    testWidgets('Shows form validation errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CheckoutPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Try to submit without filling form
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your phone number'), findsOneWidget);
      expect(find.text('Please enter your delivery address'), findsOneWidget);
    });

    testWidgets('Can submit form with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CheckoutPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Fill the form
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Phone Number'), '12345678');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Delivery Address'),
          '123 Main Street, City, Country');

      // Submit form
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
