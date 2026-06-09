import 'package:flutter_test/flutter_test.dart';
import 'package:vanix/features/subscription/providers/subscription_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 SubscriptionProvider Tests', () {
    test('checkout error handling sets isLoading to false', () async {
      final provider = SubscriptionProvider();

      expect(provider.isLoading, false);

      // Call checkout, which should fail because there is no backend/connectivity mock
      await provider.checkout('plan_123');

      // The try/catch in checkout() should handle the exception and finally set isLoading back to false.
      expect(provider.isLoading, false);
    });
  });
}
