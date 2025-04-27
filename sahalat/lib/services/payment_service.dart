import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PaymentMethod {
  final String id;
  final String type; // 'card', 'bank_transfer', 'cash'
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expiryDate': expiryDate,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        'isDefault': isDefault,
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'],
        type: json['type'],
        cardNumber: json['cardNumber'],
        cardHolderName: json['cardHolderName'],
        expiryDate: json['expiryDate'],
        bankName: json['bankName'],
        accountNumber: json['accountNumber'],
        accountHolderName: json['accountHolderName'],
        isDefault: json['isDefault'] ?? false,
      );
}

class PaymentService {
  static const String _key = 'payment_methods';

  static Future<List<PaymentMethod>> getPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => PaymentMethod.fromJson(json)).toList();
  }

  static Future<void> addPaymentMethod(PaymentMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    final methods = await getPaymentMethods();

    // If this is set as default, remove default from others
    if (method.isDefault) {
      for (var i = 0; i < methods.length; i++) {
        if (methods[i].isDefault) {
          methods[i] = PaymentMethod(
            id: methods[i].id,
            type: methods[i].type,
            cardNumber: methods[i].cardNumber,
            cardHolderName: methods[i].cardHolderName,
            expiryDate: methods[i].expiryDate,
            bankName: methods[i].bankName,
            accountNumber: methods[i].accountNumber,
            accountHolderName: methods[i].accountHolderName,
            isDefault: false,
          );
        }
      }
    }

    methods.add(method);
    await _savePaymentMethods(methods);
  }

  static Future<void> updatePaymentMethod(PaymentMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    final methods = await getPaymentMethods();
    final index = methods.indexWhere((m) => m.id == method.id);

    if (index != -1) {
      // If this is set as default, remove default from others
      if (method.isDefault) {
        for (var i = 0; i < methods.length; i++) {
          if (i != index && methods[i].isDefault) {
            methods[i] = PaymentMethod(
              id: methods[i].id,
              type: methods[i].type,
              cardNumber: methods[i].cardNumber,
              cardHolderName: methods[i].cardHolderName,
              expiryDate: methods[i].expiryDate,
              bankName: methods[i].bankName,
              accountNumber: methods[i].accountNumber,
              accountHolderName: methods[i].accountHolderName,
              isDefault: false,
            );
          }
        }
      }

      methods[index] = method;
      await _savePaymentMethods(methods);
    }
  }

  static Future<void> deletePaymentMethod(String id) async {
    final methods = await getPaymentMethods();
    methods.removeWhere((method) => method.id == id);
    await _savePaymentMethods(methods);
  }

  static Future<void> _savePaymentMethods(List<PaymentMethod> methods) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = methods.map((method) => method.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<void> clearAllPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Initialize payment service - clear any existing data
  static Future<void> initialize() async {
    await clearAllPaymentMethods();
  }

  // Simulate payment processing
  Future<bool> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
    required double amount,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Basic validation
    if (cardNumber.isEmpty ||
        expiryDate.isEmpty ||
        cvv.isEmpty ||
        cardHolderName.isEmpty) {
      throw Exception('All fields are required');
    }

    // Remove spaces from card number
    final cleanCardNumber = cardNumber.replaceAll(' ', '');

    // Basic card number validation (Luhn algorithm)
    if (!_isValidCardNumber(cleanCardNumber)) {
      throw Exception('Invalid card number');
    }

    // Basic expiry date validation (MM/YY format)
    if (!_isValidExpiryDate(expiryDate)) {
      throw Exception('Invalid expiry date');
    }

    // Basic CVV validation (3-4 digits)
    if (!_isValidCVV(cvv)) {
      throw Exception('Invalid CVV');
    }

    // In a real app, you would integrate with a payment gateway here
    // For now, we'll simulate a successful payment
    return true;
  }

  bool _isValidCardNumber(String number) {
    if (number.length < 13 || number.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    // Loop through values starting from the rightmost digit
    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    return (sum % 10 == 0);
  }

  bool _isValidExpiryDate(String expiry) {
    // Check format (MM/YY)
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) return false;

    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0);

    return month >= 1 && month <= 12 && expiryDate.isAfter(now);
  }

  bool _isValidCVV(String cvv) {
    return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }
}
