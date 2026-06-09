import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanix/features/auth/providers/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vanix/core/constants/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 AuthProvider Unit Tests', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    test('Initial State - User should be logged out', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();

      final authProvider = AuthProvider(sharedPreferences: sharedPreferences);

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
      expect(authProvider.token, null);
    });

    test('Restore session - Should restore session if cache is populated',
        () async {
      final mockUser = {
        'id': 'usr_1',
        'email': 'cached_test@vanix.com',
        'role': 'user',
        'subscriptionPlan': 'free',
        'profiles': []
      };

      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({
        AppConstants.keyToken: 'mock_access_token_123',
        AppConstants.keyRefreshToken: 'mock_refresh_token_123',
        AppConstants.keyUser: jsonEncode(mockUser),
      });
      sharedPreferences = await SharedPreferences.getInstance();

      final authProvider = AuthProvider(sharedPreferences: sharedPreferences);

      // Give loadSession time to complete asynchronously
      await Future.delayed(const Duration(milliseconds: 100));

      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, 'mock_access_token_123');
      expect(authProvider.currentUser?.email, 'cached_test@vanix.com');
    });

    test(
        'Logout - Should clear all session tokens and data from SharedPreferences',
        () async {
      final mockUser = {
        'id': 'usr_1',
        'email': 'cached_test@vanix.com',
        'role': 'user',
        'subscriptionPlan': 'free',
        'profiles': []
      };

      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({
        AppConstants.keyToken: 'mock_access_token_123',
        AppConstants.keyRefreshToken: 'mock_refresh_token_123',
        AppConstants.keyUser: jsonEncode(mockUser),
        AppConstants.keyActiveProfileId: 'prof_1',
      });
      sharedPreferences = await SharedPreferences.getInstance();

      final authProvider = AuthProvider(sharedPreferences: sharedPreferences);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(authProvider.isAuthenticated, true);

      // Perform Logout
      await authProvider.logout();

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
      expect(authProvider.token, null);

      expect(
          await const FlutterSecureStorage().read(key: AppConstants.keyToken),
          null);
      expect(
          await const FlutterSecureStorage()
              .read(key: AppConstants.keyRefreshToken),
          null);
      expect(
          await const FlutterSecureStorage()
              .read(key: AppConstants.keyActiveProfileId),
          null);
    });
  });
}
