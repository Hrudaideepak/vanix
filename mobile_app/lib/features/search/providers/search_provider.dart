import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_client.dart';
import '../../movies/models/content_model.dart';

class SearchProvider extends ChangeNotifier {
  bool _isLoading = false;

  List<ContentModel> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _trendingSearches = [];
  String _selectedGenre = 'All';
  String _selectedType = 'All';
  String? _spellingSuggestion;
  bool _typoCorrected = false;

  SearchProvider();

  // Getters
  bool get isLoading => _isLoading;
  List<ContentModel> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  List<String> get trendingSearches => _trendingSearches;
  String get selectedGenre => _selectedGenre;
  String get selectedType => _selectedType;
  String? get spellingSuggestion => _spellingSuggestion;
  bool get typoCorrected => _typoCorrected;

  void updateAuth(String? token) {}

  void updateFilters({String? genre, String? type}) {
    if (genre != null) _selectedGenre = genre;
    if (type != null) _selectedType = type;
    notifyListeners();
  }

  /// Perform smart fuzzy search
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _spellingSuggestion = null;
      _typoCorrected = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get(
        '/search/query?q=${Uri.encodeComponent(query)}&genre=$_selectedGenre&type=$_selectedType',
      );
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] as List? ?? [];
        _searchResults = list.map((c) => ContentModel.fromJson(c as Map<String, dynamic>)).toList();
        _typoCorrected = decoded['typoCorrected'] ?? false;
        _spellingSuggestion = decoded['suggestedQuery'];
        
        // Refresh recents on search
        await fetchRecentSearches();
      }
    } catch (e) {
      AppLogger.warning('Search query API failed: $e. Using local simulation...');
      _loadMockSearchResults(query);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentSearches() async {
    try {
      final response = await ApiClient.instance.get('/search/recent');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] as List? ?? [];
        _recentSearches = list.map((r) => r.toString()).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    notifyListeners();
    try {
      await ApiClient.instance.delete('/search/recent');
    } catch (_) {}
  }

  Future<void> fetchTrendingSearches() async {
    try {
      final response = await ApiClient.instance.get('/search/trending');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] as List? ?? [];
        _trendingSearches = list.map((r) => r.toString()).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  void _loadMockSearchResults(String query) {
    final allMocks = [
      ContentModel(
        id: 'mv_1',
        title: 'Nebula Genesis',
        description: 'Deep-space research anomaly.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=500&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?w=1000&q=80',
        videoUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
        type: 'movie',
        rating: 8.9,
        releaseYear: 2024,
        duration: '2h 15m',
        genres: ['Sci-Fi', 'Thriller'],
        isPremium: true,
      ),
      ContentModel(
        id: 'mv_2',
        title: 'Shadow Sector',
        description: 'Cyberpunk operative heist.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=500&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1000&q=80',
        videoUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
        type: 'movie',
        rating: 8.4,
        releaseYear: 2024,
        duration: '1h 58m',
        genres: ['Cyberpunk', 'Action'],
        isPremium: true,
      )
    ];

    _searchResults = allMocks.where((m) {
      final matchesQuery = m.title.toLowerCase().contains(query.toLowerCase());
      final matchesGenre = _selectedGenre == 'All' || m.genres.contains(_selectedGenre);
      final matchesType = _selectedType == 'All' || m.type == _selectedType.toLowerCase();
      return matchesQuery && matchesGenre && matchesType;
    }).toList();
  }
}
