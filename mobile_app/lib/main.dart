import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart'; // Re-enable with Firebase
import 'app.dart';

// Providers (will be implemented in subsequent files)
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/movies/providers/movie_provider.dart';
import 'features/player/providers/playback_provider.dart';
import 'features/watchlist/providers/watchlist_provider.dart';
import 'features/downloads/providers/download_provider.dart';
import 'features/search/providers/search_provider.dart';
import 'features/subscription/providers/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization (disabled until google-services.json is added)
  // try {
  //   await Firebase.initializeApp();
  //   print("🔥 Firebase initialized successfully!");
  // } catch (e) {
  //   print("⚠️ Firebase initialization bypassed: $e");
  // }
  
  // Set preferred orientations to portrait first, player will handle landscape rotation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style for premium cinematic look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF050505),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: sharedPreferences),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(sharedPreferences: sharedPreferences),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (context) => ProfileProvider(sharedPreferences: sharedPreferences),
          update: (context, auth, previous) =>
              previous!..updateAuth(auth.token, auth.currentUser),
        ),
        ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
          create: (context) => HomeProvider(),
          update: (context, auth, previous) =>
              previous!..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MovieProvider>(
          create: (context) => MovieProvider(),
          update: (context, auth, previous) =>
              previous!..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PlaybackProvider>(
          create: (context) => PlaybackProvider(),
          update: (context, auth, previous) =>
              previous!..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WatchlistProvider>(
          create: (context) => WatchlistProvider(),
          update: (context, auth, previous) =>
              previous!..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DownloadProvider>(
          create: (context) => DownloadProvider(sharedPreferences: sharedPreferences),
          update: (context, auth, previous) =>
              previous!..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SearchProvider>(
          create: (context) => SearchProvider(),
          update: (context, auth, previous) =>
              previous!..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
          create: (context) => SubscriptionProvider(),
          update: (context, auth, previous) =>
              previous!..updateAuth(auth.token),
        ),
      ],
      child: const VanixApp(),
    ),
  );
}
