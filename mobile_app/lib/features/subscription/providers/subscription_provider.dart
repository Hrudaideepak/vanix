import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_client.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _isLoading = false;

  SubscriptionProvider();

  bool get isLoading => _isLoading;

  void updateAuth(String? token) {}

  Future<Map<String, dynamic>?> checkout(String planId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/checkout', body: {'planId': planId});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      AppLogger.error('Checkout API failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String planId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/verify-payment', body: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
        'planId': planId,
      });

      if (response.statusCode == 200) {
        AppLogger.info('Subscription successfully verified and activated!');
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      AppLogger.error('Verify payment failed: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
