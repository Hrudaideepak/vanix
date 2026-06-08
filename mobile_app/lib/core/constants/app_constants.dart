import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConstants {
  AppConstants._();

  // API Configurations
  // On android emulator, 10.0.2.2 points to host machine localhost
  static String get apiBaseUrl {
    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      return 'http://$host:5000/api';
    }
    return 'http://192.168.29.161:5000/api';
  }
  
  // Storage Keys
  static const String keyToken = 'vanix_auth_token';
  static const String keyRefreshToken = 'vanix_refresh_token';
  static const String keyUser = 'vanix_user_data';
  static const String keyActiveProfileId = 'vanix_active_profile_id';
  static const String keyOfflineDownloads = 'vanix_downloads_list';
  static const String keyWatchHistory = 'vanix_watch_history_list';

  // API Endpoints
  static const String pathRegister = '/register';
  static const String pathLogin = '/login';
  static const String pathRefreshToken = '/refresh-token';
  static const String pathGoogleLogin = '/google-login';
  static const String pathLogout = '/logout';
  static const String pathProfile = '/profile';
  
  static const String pathMovies = '/movies';
  static const String pathSeries = '/series';
  static const String pathCategories = '/categories';
  static const String pathSearch = '/search';
  
  static const String pathWatchlist = '/watchlist';
  static const String pathHistory = '/history';
  
  static const String pathUploadMovie = '/uploadMovie';
  static const String pathUploadSeries = '/uploadSeries';
  static const String pathUploadEpisode = '/uploadEpisode';
  static const String pathUploadTrailer = '/uploadTrailer';

  // Subscription Plans
  static const List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': 'free',
      'name': 'Free',
      'price': '0',
      'duration': 'Lifetime',
      'features': [
        'Contains Ads',
        'Standard Definition (SD)',
        '1 Active Screen',
        'No Downloads',
      ],
    },
    {
      'id': 'silver',
      'name': 'Silver',
      'price': '199',
      'duration': 'Month',
      'features': [
        'Ad-Free Streaming',
        'High Definition (HD)',
        '2 Active Screens',
        'Standard Offline Downloads',
      ],
    },
    {
      'id': 'gold',
      'name': 'Gold',
      'price': '499',
      'duration': '3 Months',
      'features': [
        'Ad-Free Streaming',
        'Full HD (1080p)',
        '3 Active Screens',
        'Dolby Audio Support',
        'Unlimited Downloads',
      ],
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'price': '999',
      'duration': 'Year',
      'features': [
        'Ad-Free Streaming',
        '4K Ultra HD & HDR',
        '5 Active Screens',
        'Dolby Atmos Sound',
        'Unlimited Downloads',
        'Family Sharing Access',
      ],
    },
  ];
}
