import 'package:flutter/material.dart';
import 'package:sahalat/models/cart_item.dart';
import 'package:sahalat/services/cart_service.dart';
import 'package:sahalat/theme/app_theme.dart';
import 'package:sahalat/widgets/custom_button.dart';
import 'package:sahalat/services/navigation_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _formKey = GlobalKey<FormState>();
  final _navigationService = NavigationService();
  bool _isLoading = true;
  String? _error;
  List<CartItem> _cartItems = [];
  double _subtotal = 0;
  double _deliveryFee = 5.0; // Example fixed delivery fee
  double _tax = 0;
  bool _hasMultipleRestaurants = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await CartService.getCartItems();
      if (!mounted) return;

      // Check if items are from multiple restaurants
      if (items.isNotEmpty) {
        final firstRestaurantId = items[0].restaurantId;
        _hasMultipleRestaurants =
            items.any((item) => item.restaurantId != firstRestaurantId);
      }

      setState(() {
        _cartItems = items;
        _isLoading = false;
        _calculateTotals();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load cart items. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _calculateTotals() {
    _subtotal = _cartItems.fold(0, (sum, item) => sum + item.total);
    _tax = _subtotal * 0.15; // Example 15% tax
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) {
      _showRemoveItemDialog(item);
      return;
    }

    try {
      final updatedItem = item.copyWith(quantity: newQuantity);
      await CartService.updateCartItem(updatedItem);
      await _loadCartItems();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update quantity. Please try again.')),
      );
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      await CartService.removeFromCart(item.id);
      await _loadCartItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} removed from cart')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to remove item. Please try again.')),
      );
    }
  }

  void _showRemoveItemDialog(CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${item.name} from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeItem(item);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCart() async {
    try {
      await CartService.clearCart();
      await _loadCartItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart cleared')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to clear cart. Please try again.')),
      );
    }
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout() {
    if (_hasMultipleRestaurants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please order from only one restaurant at a time'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // TODO: Implement checkout navigation
    Navigator.pushNamed(context, '/checkout');
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items from restaurants to start ordering',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () {
              // Navigate to vendors page
              Navigator.pushReplacementNamed(context, '/vendors');
            },
            text: 'Browse Restaurants',
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.image!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.restaurantName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (item.note != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${item.note}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'OMR ${item.price.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () =>
                            _updateQuantity(item, item.quantity - 1),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            _updateQuantity(item, item.quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('OMR ${_subtotal.toStringAsFixed(3)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Fee'),
                Text('OMR ${_deliveryFee.toStringAsFixed(3)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax'),
                Text('OMR ${_tax.toStringAsFixed(3)}'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'OMR ${(_subtotal + _deliveryFee + _tax).toStringAsFixed(3)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCartItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_cartItems.isEmpty) {
      content = _buildEmptyState();
    } else {
      content = RefreshIndicator(
        onRefresh: _loadCartItems,
        child: Column(
          children: [
            if (_hasMultipleRestaurants)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange[100],
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have items from multiple restaurants. Please order from one restaurant at a time.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cart (${_cartItems.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showClearCartDialog,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Clear Cart'),
                        ),
                      ],
                    ),
                  ),
                  ..._cartItems.map(_buildCartItem),
                  _buildTotalSection(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                onPressed: _navigateToCheckout,
                text: 'Proceed to Checkout',
                isDisabled: _hasMultipleRestaurants,
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: content,
      ),
    );
  }
}
