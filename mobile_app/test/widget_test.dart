import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanix/app.dart';
import 'package:vanix/features/auth/providers/auth_provider.dart';
import 'package:vanix/features/profile/providers/profile_provider.dart';
import 'package:vanix/features/home/providers/home_provider.dart';
import 'package:vanix/features/movies/providers/movie_provider.dart';
import 'package:vanix/features/player/providers/playback_provider.dart';
import 'package:vanix/features/watchlist/providers/watchlist_provider.dart';
import 'package:vanix/features/downloads/providers/download_provider.dart';
import 'package:vanix/features/search/providers/search_provider.dart';
import 'package:vanix/features/subscription/providers/subscription_provider.dart';

void main() {
  testWidgets('VanixApp splash screen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
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

    // Verify that the splash/brand logo displays
    expect(find.text('VANIX'), findsOneWidget);

    // Let the splash transition timer fire (3 seconds delay) and navigate to login
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
