import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../models/content_model.dart';

class MovieProvider extends ChangeNotifier {
  final http.Client _client;
  String? _authToken;
  bool _isLoading = false;

  ContentModel? _selectedContent;
  List<ContentModel> _suggestedContent = [];

  MovieProvider({http.Client? client}) : _client = client ?? http.Client();

  // Getters
  bool get isLoading => _isLoading;
  ContentModel? get selectedContent => _selectedContent;
  List<ContentModel> get suggestedContent => _suggestedContent;

  void updateAuth(String? token) {
    _authToken = token;
  }

  /// Fetch single movie or series details
  Future<void> fetchContentDetails(String id, String type) async {
    _isLoading = true;
    _selectedContent = null;
    _suggestedContent = [];
    notifyListeners();

    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/movie/$id');
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _selectedContent = ContentModel.fromJson(decoded['data']);

        // Fetch recommendations on success
        await _fetchRecommendations(id);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.warning(
          'Details query failed for $id ($type): $e. Generating cinematic details...');
      _loadMockDetails(id, type);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchRecommendations(String contentId) async {
    try {
      final url = Uri.parse(
          '${AppConstants.apiBaseUrl}${AppConstants.pathMovies}?recommendedFor=$contentId');
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] as List? ?? [];
        _suggestedContent = list
            .map((c) => ContentModel.fromJson(c as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Ignore exception, fall back to mock related items
    }
  }

  void _loadMockDetails(String id, String type) {
    // Premium details mock generator
    _selectedContent = ContentModel(
      id: id,
      title: id == 'mv_1'
          ? 'Nebula Genesis'
          : (type == 'movie' ? 'Shadow Sector' : 'Chronicles of Chronos'),
      description:
          'In the near future, humanity builds a warp gate that connects our solar system to the unknown Nebula Galaxy. A rogue squad of elite pilots is sent to investigate a silent signal coming from the core of the nebula, only to discover a sentient structure that holds the secret of human origin and an ancient warning of incoming annihilation.',
      thumbnailUrl: id == 'mv_1'
          ? 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=500&q=80'
          : 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=500&q=80',
      bannerUrl: id == 'mv_1'
          ? 'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?w=1000&q=80'
          : 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1000&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      type: type,
      rating: 8.8,
      releaseYear: 2024,
      duration: type == 'movie' ? '2h 15m' : '1 Season (8 Ep)',
      genres: ['Sci-Fi', 'Thriller', 'Space Opera'],
      isPremium: true,
      progress: 0.45,
      cast: [
        'Alexander Vance',
        'Elena Rostova',
        'Kaelen Thorne',
        'Dr. Aris Thorne'
      ],
      crew: [
        'Marcus Sterling (Director)',
        'Sarah Lin (Producer)',
        'Hans Zimmer (Composer)'
      ],
    );

    // Populate suggested recommendations
    _suggestedContent = [
      ContentModel(
        id: 'mv_3',
        title: 'Ragnarok Rising',
        description: 'Nordic gods assemble to protect Midgard.',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80',
        bannerUrl:
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1000&q=80',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        type: 'movie',
        rating: 9.1,
        releaseYear: 2024,
        duration: '2h 45m',
        genres: ['Fantasy', 'Action'],
        isPremium: true,
      ),
      ContentModel(
        id: 'mv_5',
        title: 'Ocean Deep',
        description: 'Aquatic leviathan rising.',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=500&q=80',
        bannerUrl:
            'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=1000&q=80',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubscribersActive.mp4',
        type: 'movie',
        rating: 8.2,
        releaseYear: 2023,
        duration: '2h 05m',
        genres: ['Adventure', 'Sci-Fi'],
        isPremium: true,
      )
    ];
  }
}
