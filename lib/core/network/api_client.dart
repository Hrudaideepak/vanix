import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class ApiClient {
  static final ApiClient instance = ApiClient();

  final http.Client _client;
  final Connectivity _connectivity;
  String? _authToken;
  String? _activeProfileId;
  Future<bool> Function()? _onTokenExpired;

  ApiClient({
    http.Client? client,
    Connectivity? connectivity,
  })  : _client = client ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  void updateToken(String? token, {String? refreshToken}) {
    _authToken = token;
    AppLogger.debug(
        'ApiClient Token updated: ${token != null ? "Token set (len: ${token.length})" : "Token cleared"}');
  }

  void updateActiveProfile(String? profileId) {
    _activeProfileId = profileId;
    AppLogger.debug('ApiClient Active Profile updated: $profileId');
  }

  void setTokenExpiryCallback(Future<bool> Function() callback) {
    _onTokenExpired = callback;
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw const SocketException('No Internet Connection');
    }
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (_activeProfileId != null) {
      headers['x-profile-id'] = _activeProfileId!;
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    await _checkConnectivity();
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    AppLogger.debug('GET Request: $url');

    try {
      var response = await _client
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 3));

      // Auto-retry once on 401 if token refresh logic is registered
      if (response.statusCode == 401 && _onTokenExpired != null) {
        AppLogger.warning(
            'Unauthorized response (401) on GET. Refreshing token...');
        final refreshed = await _onTokenExpired!();
        if (refreshed) {
          AppLogger.debug('Token refreshed. Retrying GET Request: $url');
          response = await _client
              .get(url, headers: _getHeaders())
              .timeout(const Duration(seconds: 3));
        }
      }
      return _processResponse(response);
    } catch (e) {
      AppLogger.error('GET Request Error: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    await _checkConnectivity();
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final stringBody = body != null ? jsonEncode(body) : null;
    AppLogger.debug('POST Request: $url | Body: $stringBody');

    try {
      var response = await _client
          .post(
            url,
            headers: _getHeaders(),
            body: stringBody,
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 401 && _onTokenExpired != null) {
        AppLogger.warning(
            'Unauthorized response (401) on POST. Refreshing token...');
        final refreshed = await _onTokenExpired!();
        if (refreshed) {
          AppLogger.debug('Token refreshed. Retrying POST Request: $url');
          response = await _client
              .post(
                url,
                headers: _getHeaders(),
                body: stringBody,
              )
              .timeout(const Duration(seconds: 3));
        }
      }
      return _processResponse(response);
    } catch (e) {
      AppLogger.error('POST Request Error: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint) async {
    await _checkConnectivity();
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    AppLogger.debug('DELETE Request: $url');

    try {
      var response = await _client
          .delete(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 401 && _onTokenExpired != null) {
        AppLogger.warning(
            'Unauthorized response (401) on DELETE. Refreshing token...');
        final refreshed = await _onTokenExpired!();
        if (refreshed) {
          AppLogger.debug('Token refreshed. Retrying DELETE Request: $url');
          response = await _client
              .delete(url, headers: _getHeaders())
              .timeout(const Duration(seconds: 3));
        }
      }
      return _processResponse(response);
    } catch (e) {
      AppLogger.error('DELETE Request Error: $e');
      rethrow;
    }
  }

  http.Response _processResponse(http.Response response) {
    AppLogger.debug('Response Code: ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      final body = response.body;
      String errorMessage = 'Server error occurred (${response.statusCode})';
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded.containsKey('message')) {
          errorMessage = decoded['message'];
        }
      } catch (_) {}
      throw HttpException(errorMessage);
    }
  }
}

class HttpException implements Exception {
  final String message;
  const HttpException(this.message);

  @override
  String toString() => message;
}
