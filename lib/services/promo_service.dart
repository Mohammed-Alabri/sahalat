import 'package:cloud_firestore/cloud_firestore.dart';

class PromoService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<double> applyPromoCode(String code, double subtotal) async {
    try {
      final promoDoc = await _firestore
          .collection('promo_codes')
          .doc(code.toUpperCase())
          .get();

      if (!promoDoc.exists) {
        throw Exception('Invalid promo code');
      }

      final data = promoDoc.data()!;
      final isActive = data['isActive'] ?? false;
      if (!isActive) {
        throw Exception('This promo code has expired');
      }

      final minOrderValue = (data['minOrderValue'] ?? 0.0).toDouble();
      if (subtotal < minOrderValue) {
        throw Exception(
            'Minimum order value of \$${minOrderValue.toStringAsFixed(2)} required');
      }

      final discountType = data['discountType'] ?? 'percentage';
      final discountValue = (data['discountValue'] ?? 0.0).toDouble();
      final maxDiscount = (data['maxDiscount'] ?? double.infinity).toDouble();

      double discount;
      if (discountType == 'percentage') {
        discount = (subtotal * discountValue / 100);
        if (discount > maxDiscount) {
          discount = maxDiscount;
        }
      } else {
        discount = discountValue;
      }

      return discount;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to apply promo code');
    }
  }

  static Future<void> createPromoCode({
    required String code,
    required double discountValue,
    required String discountType,
    double? maxDiscount,
    double? minOrderValue,
    DateTime? expiryDate,
  }) async {
    try {
      await _firestore.collection('promo_codes').doc(code.toUpperCase()).set({
        'code': code.toUpperCase(),
        'discountValue': discountValue,
        'discountType': discountType,
        'maxDiscount': maxDiscount,
        'minOrderValue': minOrderValue,
        'expiryDate': expiryDate,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create promo code: $e');
    }
  }
} 