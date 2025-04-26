import 'package:flutter/material.dart';
import 'package:sahalat/models/order.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data from API
    final orders = [
      Order(
        id: '1',
        userId: 'user1',
        restaurantId: 'rest1',
        items: [
          OrderItem(
            productId: '1',
            productName: 'Shuwa',
            quantity: 2,
            price: 15.0,
          ),
          OrderItem(
            productId: '2',
            productName: 'Harees',
            quantity: 1,
            price: 10.0,
          ),
        ],
        totalAmount: 40.0,
        status: 'Delivered',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        deliveryAddress: '123 Muscat Street, Oman',
        deliveryNotes: 'Please call before delivery',
      ),
      // Add more orders here
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body:
          orders.isEmpty
              ? const Center(child: Text('No orders yet'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Date: ${_formatDate(order.orderDate)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Items:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Text(
                                '${item.quantity}x ${item.productName}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: OMR ${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Implement reorder functionality
                                },
                                child: const Text('Reorder'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
