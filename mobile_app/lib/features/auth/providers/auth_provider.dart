import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../data/auth_service.dart';
import '../models/user_model.dart';
import 'dart:io' show Platform;
// import 'package:firebase_messaging/firebase_messaging.dart'; // Re-enable with Firebase

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthService _authService;

  UserModel? _currentUser;
  String? _token;
  String? _refreshToken;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required SharedPreferences sharedPreferences,
    AuthService? authService,
  })  : _prefs = sharedPreferences,
        _authService = authService ?? AuthService() {
    _loadSession();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load session from local storage on startup
  void _loadSession() {
    final token = _prefs.getString(AppConstants.keyToken);
    final refreshToken = _prefs.getString(AppConstants.keyRefreshToken);
    final userJson = _prefs.getString(AppConstants.keyUser);

    if (token != null && refreshToken != null && userJson != null) {
      try {
        _token = token;
        _refreshToken = refreshToken;
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        AppLogger.info('Session restored for: ${_currentUser?.email}');
        syncDevicePushToken();
      } catch (e) {
        AppLogger.error('Failed to parse cached session: $e');
        _clearSession();
      }
    }
  }

  /// Generate or fetch stored device ID
  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = _prefs.getString('vanix_device_id');
    if (deviceId == null) {
      final rand = '${DateTime.now().microsecondsSinceEpoch}_${100000 + (DateTime.now().millisecond * 100)}';
      deviceId = 'dev_$rand';
      await _prefs.setString('vanix_device_id', deviceId);
    }
    return deviceId;
  }

  /// Determine platform device name
  String _getDeviceName() {
    if (kIsWeb) return 'Web Browser';
    return Platform.isAndroid
        ? 'Android Device'
        : Platform.isIOS
            ? 'iPhone/iPad'
            : 'Desktop/Other App';
  }

  /// Register User
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final deviceId = await _getOrCreateDeviceId();
      final deviceName = _getDeviceName();
      final response = await _authService.register(
        email,
        password,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      await _saveSession(
        token: response['accessToken'],
        refreshToken: response['refreshToken'],
        userData: response['user'],
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Login User
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final deviceId = await _getOrCreateDeviceId();
      final deviceName = _getDeviceName();
      final response = await _authService.login(
        email,
        password,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      await _saveSession(
        token: response['accessToken'],
        refreshToken: response['refreshToken'],
        userData: response['user'],
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Refresh token callback (to be wired into ApiClient)
  Future<bool> refreshSessionToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _authService.refreshAccessToken(_refreshToken!);
      final newAccessToken = response['accessToken'];
      
      _token = newAccessToken;
      await _prefs.setString(AppConstants.keyToken, newAccessToken);
      
      AppLogger.info('Access Token successfully refreshed.');
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Refresh token expired or failed: $e');
      logout();
      return false;
    }
  }

  /// Logout User
  Future<void> logout() async {
    _setLoading(true);
    _clearSession();
    _setLoading(false);
  }

  // Helper: Save session data locally
  Future<void> _saveSession({
    required String token,
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    _token = token;
    _refreshToken = refreshToken;
    _currentUser = UserModel.fromJson(userData);

    await _prefs.setString(AppConstants.keyToken, token);
    await _prefs.setString(AppConstants.keyRefreshToken, refreshToken);
    await _prefs.setString(AppConstants.keyUser, jsonEncode(userData));
    
    notifyListeners();
    syncDevicePushToken();
  }

  // Helper: Clear local storage session
  void _clearSession() {
    _token = null;
    _refreshToken = null;
    _currentUser = null;

    _prefs.remove(AppConstants.keyToken);
    _prefs.remove(AppConstants.keyRefreshToken);
    _prefs.remove(AppConstants.keyUser);
    _prefs.remove(AppConstants.keyActiveProfileId);

    notifyListeners();
  }

  /// Sync client's FCM token with the backend
  Future<void> syncDevicePushToken() async {
    // Firebase Cloud Messaging sync (disabled until Firebase is configured)
    // if (!isAuthenticated || _token == null) return;
    // try {
    //   final fcmToken = await FirebaseMessaging.instance.getToken();
    //   final deviceId = await _getOrCreateDeviceId();
    //   if (fcmToken != null) {
    //     final response = await _authService.registerFCMToken(
    //       token: _token!,
    //       deviceId: deviceId,
    //       fcmToken: fcmToken,
    //     );
    //     AppLogger.info('FCM Token synchronized with server: $response');
    //   }
    // } catch (e) {
    //   AppLogger.warning('Failed to sync push token: $e');
    // }
    AppLogger.info('FCM sync skipped — Firebase not yet configured');
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
