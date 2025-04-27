import 'package:flutter/material.dart';
import 'package:sahalat/models/restaurant.dart';
import 'package:sahalat/models/cart_item.dart';
import 'package:sahalat/services/cart_service.dart';
import 'package:sahalat/theme/app_theme.dart';
import 'package:sahalat/pages/main_layout.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsPage({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  final Map<String, int> _cartItems = {};
  double _total = 0.0;

  void _updateCart(MenuItem item, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cartItems.remove(item.id);
      } else {
        _cartItems[item.id] = quantity;
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var item in widget.restaurant.menu) {
      final quantity = _cartItems[item.id] ?? 0;
      total += item.price * quantity;
    }
    setState(() {
      _total = total;
    });
  }

  Future<void> _addToCart() async {
    try {
      if (_cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select items to add to cart')),
        );
        return;
      }

      // Add items to cart
      for (var entry in _cartItems.entries) {
        final item =
            widget.restaurant.menu.firstWhere((i) => i.id == entry.key);
        await CartService.addToCart(
          CartItem(
            id: item.id,
            name: item.name,
            price: item.price,
            quantity: entry.value,
            image: item.image,
            restaurantId: widget.restaurant.id,
            restaurantName: widget.restaurant.name,
          ),
        );
      }

      if (mounted) {
        // Pop back to the previous screen
        Navigator.pop(context);

        // Find MainLayout and switch to cart tab
        final mainLayoutState =
            context.findAncestorStateOfType<MainLayoutState>();
        if (mainLayoutState != null) {
          mainLayoutState.switchToPage(2); // Index 2 is the cart tab
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Items added to cart successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.restaurant.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
              title: Text(
                widget.restaurant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.restaurant.rating.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.restaurant.deliveryTime,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.restaurant.categories.join(' • '),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.restaurant.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = widget.restaurant.menu[index];
                final quantity = _cartItems[item.id] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Colors.grey,
                                  ),
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
                                item.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'OMR ${item.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _updateCart(item, quantity - 1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppTheme.primaryColor,
                                ),
                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _updateCart(item, quantity + 1),
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: widget.restaurant.menu.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'OMR ${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
