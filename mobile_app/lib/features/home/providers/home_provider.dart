import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_client.dart';
import '../../movies/models/content_model.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;

  List<ContentModel> _featuredBanners = [];
  List<ContentModel> _continueWatching = [];
  List<ContentModel> _trendingNow = [];
  List<ContentModel> _recommended = [];
  List<ContentModel> _becauseYouWatched = [];
  String _becauseYouWatchedTitle = 'Because You Watched';
  List<ContentModel> _latestReleases = [];

  HomeProvider();

  // Getters
  bool get isLoading => _isLoading;
  List<ContentModel> get featuredBanners => _featuredBanners;
  List<ContentModel> get continueWatching => _continueWatching;
  List<ContentModel> get trendingNow => _trendingNow;
  List<ContentModel> get recommended => _recommended;
  List<ContentModel> get becauseYouWatched => _becauseYouWatched;
  String get becauseYouWatchedTitle => _becauseYouWatchedTitle;
  List<ContentModel> get latestReleases => _latestReleases;

  void updateAuth(String? token) {}

  /// Fetch all home screen shelves from personalization engine APIs
  Future<void> fetchHomeScreen() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch personalization feeds
      final recResponse = await ApiClient.instance.get('/recommendations');
      
      // 2. Fetch watch history (for continue watching)
      final histResponse = await ApiClient.instance.get('/history');

      if (recResponse.statusCode == 200 && histResponse.statusCode == 200) {
        final recDecoded = jsonDecode(recResponse.body)['data'];
        final histDecoded = jsonDecode(histResponse.body)['data'] as List? ?? [];

        // Parse featured
        final featList = recDecoded['featured'] as List? ?? [];
        _featuredBanners = featList.map((c) => ContentModel.fromJson(c)).toList();

        // Parse sections
        final sections = recDecoded['sections'] as List? ?? [];
        for (var section in sections) {
          final key = section['key'];
          final title = section['title'] ?? '';
          final dataList = section['data'] as List? ?? [];
          final movies = dataList.map((c) => ContentModel.fromJson(c)).toList();

          if (key == 'because_you_watched') {
            _becauseYouWatched = movies;
            _becauseYouWatchedTitle = title;
          } else if (key == 'recommended_for_you') {
            _recommended = movies;
          } else if (key == 'trending_near_you') {
            _trendingNow = movies;
          }
        }

        // Parse continue watching from history items
        _continueWatching = histDecoded
            .map((h) {
              final movieData = h['movie'];
              if (movieData == null) return null;
              final progress = h['progress'] as double? ?? 0.0;
              // Map continue watching movie progress
              final content = ContentModel.fromJson(movieData);
              return ContentModel(
                id: content.id,
                title: content.title,
                description: content.description,
                thumbnailUrl: content.thumbnailUrl,
                bannerUrl: content.bannerUrl,
                videoUrl: content.videoUrl,
                type: content.type,
                rating: content.rating,
                releaseYear: content.releaseYear,
                duration: content.duration,
                genres: content.genres,
                isPremium: content.isPremium,
                progress: progress,
                cast: content.cast,
                crew: content.crew,
              );
            })
            .whereType<ContentModel>()
            .where((m) => m.progress > 0.0 && m.progress < 0.95) // active progress check
            .toList();

        // Populate fallback latest releases list
        _latestReleases = [..._trendingNow, ..._recommended].take(4).toList();

      } else {
        throw Exception('Server returned error status');
      }
    } catch (e) {
      AppLogger.warning('Fetch Home personalization failed: $e. Generating cinematic mock shelves...');
      _loadMockShelves();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMockShelves() {
    final mocks = [
      ContentModel(
        id: 'mv_1',
        title: 'Nebula Genesis',
        description: 'In the year 2350, a deep-space research pilot discovers a cosmic energy anomaly.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=500&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?w=1000&q=80',
        videoUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
        type: 'movie',
        rating: 8.9,
        releaseYear: 2024,
        duration: '2h 15m',
        genres: ['Sci-Fi', 'Thriller'],
        isPremium: true,
        progress: 0.65,
      ),
      ContentModel(
        id: 'mv_2',
        title: 'Shadow Sector',
        description: 'An elite cyberpunk operative is blackmailed into executing the heist of the century.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=500&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1000&q=80',
        videoUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
        type: 'movie',
        rating: 8.4,
        releaseYear: 2024,
        duration: '1h 58m',
        genres: ['Cyberpunk', 'Action'],
        isPremium: true,
        progress: 0.12,
      ),
      ContentModel(
        id: 'mv_5',
        title: 'Ocean Deep',
        description: 'An exploration team investigating the Mariana Trench encounters a prehistoric aquatic leviathan.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=500&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=1000&q=80',
        videoUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
        type: 'movie',
        rating: 8.2,
        releaseYear: 2023,
        duration: '2h 05m',
        genres: ['Kids', 'Animation', 'Family'],
        isPremium: true,
        progress: 0.45,
      )
    ];

    _featuredBanners = mocks.take(2).toList();
    _trendingNow = mocks.where((m) => m.rating >= 8.4).toList();
    _recommended = mocks.where((m) => m.isPremium).toList();
    _becauseYouWatched = mocks.where((m) => m.genres.contains('Sci-Fi')).toList();
    _becauseYouWatchedTitle = 'Because you watched Nebula Genesis';
    _latestReleases = mocks.toList();
    _continueWatching = mocks.where((m) => m.progress > 0.0).toList();
  }
}
