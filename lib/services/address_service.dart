import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DeliveryAddress {
  final String id;
  final String name;
  final String wilayat;
  final String area;
  final String street;
  final String building;
  final String? apartment;
  final String? landmark;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.name,
    required this.wilayat,
    required this.area,
    required this.street,
    required this.building,
    this.apartment,
    this.landmark,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'wilayat': wilayat,
        'area': area,
        'street': street,
        'building': building,
        'apartment': apartment,
        'landmark': landmark,
        'isDefault': isDefault,
      };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        id: json['id'],
        name: json['name'],
        wilayat: json['wilayat'],
        area: json['area'],
        street: json['street'],
        building: json['building'],
        apartment: json['apartment'],
        landmark: json['landmark'],
        isDefault: json['isDefault'] ?? false,
      );
}

class AddressService {
  static final List<DeliveryAddress> _addresses = [];
  static const String _storageKey = 'delivery_addresses';

  static Future<List<DeliveryAddress>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getStringList(_storageKey) ?? [];
    return addressesJson
        .map((json) => DeliveryAddress.fromJson(
            Map<String, dynamic>.from(jsonDecode(json))))
        .toList();
  }

  static Future<void> addAddress(DeliveryAddress address) async {
    final addresses = await getAddresses();

    // If this is the first address or marked as default, unset other defaults
    if (address.isDefault || addresses.isEmpty) {
      for (var addr in addresses) {
        if (addr.isDefault) {
          final updatedAddr = DeliveryAddress(
            id: addr.id,
            name: addr.name,
            wilayat: addr.wilayat,
            area: addr.area,
            street: addr.street,
            building: addr.building,
            apartment: addr.apartment,
            landmark: addr.landmark,
            isDefault: false,
          );
          await updateAddress(updatedAddr);
        }
      }
    }

    addresses.add(address);
    await _saveAddresses(addresses);
  }

  static Future<void> updateAddress(DeliveryAddress address) async {
    final addresses = await getAddresses();
    final index = addresses.indexWhere((addr) => addr.id == address.id);
    if (index != -1) {
      // If setting as default, unset other defaults
      if (address.isDefault) {
        for (var i = 0; i < addresses.length; i++) {
          if (i != index && addresses[i].isDefault) {
            addresses[i] = DeliveryAddress(
              id: addresses[i].id,
              name: addresses[i].name,
              wilayat: addresses[i].wilayat,
              area: addresses[i].area,
              street: addresses[i].street,
              building: addresses[i].building,
              apartment: addresses[i].apartment,
              landmark: addresses[i].landmark,
              isDefault: false,
            );
          }
        }
      }
      addresses[index] = address;
      await _saveAddresses(addresses);
    }
  }

  static Future<void> deleteAddress(String id) async {
    final addresses = await getAddresses();
    addresses.removeWhere((addr) => addr.id == id);
    await _saveAddresses(addresses);
  }

  static Future<void> _saveAddresses(List<DeliveryAddress> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson =
        addresses.map((addr) => jsonEncode(addr.toJson())).toList();
    await prefs.setStringList(_storageKey, addressesJson);
  }
}
