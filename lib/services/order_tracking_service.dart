import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingService extends ChangeNotifier {
  OrderStatus _currentStatus = OrderStatus.orderReceived;
  LatLng _driverLocation = const LatLng(23.5890, 58.3839);
  Timer? _updateTimer;
  DateTime? _estimatedDeliveryTime;

  OrderStatus get currentStatus => _currentStatus;
  LatLng get driverLocation => _driverLocation;
  DateTime? get estimatedDeliveryTime => _estimatedDeliveryTime;

  OrderTrackingService() {
    // Initialize with a 30-minute estimated delivery time
    _estimatedDeliveryTime = DateTime.now().add(const Duration(minutes: 30));
    _startUpdating();
  }

  void _startUpdating() {
    // Simulate status updates every 10 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateOrderStatus();
    });
  }

  void _updateOrderStatus() {
    switch (_currentStatus) {
      case OrderStatus.orderReceived:
        _currentStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        _currentStatus = OrderStatus.onTheWay;
        break;
      case OrderStatus.onTheWay:
        // Simulate driver movement
        _updateDriverLocation();
        break;
      case OrderStatus.delivered:
        _updateTimer?.cancel();
        break;
    }
    notifyListeners();
  }

  void _updateDriverLocation() {
    // Simulate driver moving towards delivery location
    const deliveryLocation = LatLng(23.5880, 58.3829);
    const step = 0.0001; // Small step for smooth movement

    if (_driverLocation.latitude > deliveryLocation.latitude) {
      _driverLocation =
          LatLng(_driverLocation.latitude - step, _driverLocation.longitude);
    }
    if (_driverLocation.longitude > deliveryLocation.longitude) {
      _driverLocation =
          LatLng(_driverLocation.latitude, _driverLocation.longitude - step);
    }

    // Check if driver has arrived
    const threshold = 0.0002;
    if ((_driverLocation.latitude - deliveryLocation.latitude).abs() <
            threshold &&
        (_driverLocation.longitude - deliveryLocation.longitude).abs() <
            threshold) {
      _currentStatus = OrderStatus.delivered;
    }
  }

  String getEstimatedTimeText() {
    if (_estimatedDeliveryTime == null) return 'Calculating...';

    final now = DateTime.now();
    final difference = _estimatedDeliveryTime!.difference(now);

    if (difference.inMinutes <= 0) {
      return 'Arriving soon';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '$hours hr $minutes min';
    }
  }

  String getStatusText() {
    switch (_currentStatus) {
      case OrderStatus.orderReceived:
        return 'Order received';
      case OrderStatus.preparing:
        return 'Preparing your order';
      case OrderStatus.onTheWay:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

enum OrderStatus {
  orderReceived,
  preparing,
  onTheWay,
  delivered,
}
