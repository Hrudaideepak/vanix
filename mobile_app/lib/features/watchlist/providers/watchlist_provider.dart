import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_client.dart';
import '../../movies/models/content_model.dart';

class WatchlistProvider extends ChangeNotifier {
  List<ContentModel> _watchlistItems = [];
  bool _isLoading = false;

  WatchlistProvider();

  List<ContentModel> get watchlistItems => _watchlistItems;
  bool get isLoading => _isLoading;

  void updateAuth(String? token) {}

  bool isInWatchlist(String contentId) {
    return _watchlistItems.any((item) => item.id == contentId);
  }

  Future<void> fetchWatchlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/watchlist');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] as List? ?? [];
        _watchlistItems = list.map((c) => ContentModel.fromJson(c as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      AppLogger.warning('Fetch watchlist failed: $e.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWatchlist(ContentModel movie) async {
    if (isInWatchlist(movie.id)) return;

    _watchlistItems.add(movie);
    notifyListeners();

    try {
      await ApiClient.instance.post('/watchlist', body: {'movieId': movie.id});
      AppLogger.info('Added to backend watchlist: ${movie.title}');
    } catch (e) {
      AppLogger.warning('Sync add watchlist failed: $e');
    }
  }

  Future<void> removeFromWatchlist(String contentId) async {
    _watchlistItems.removeWhere((item) => item.id == contentId);
    notifyListeners();

    try {
      await ApiClient.instance.delete('/watchlist/$contentId');
      AppLogger.info('Removed from backend watchlist: $contentId');
    } catch (e) {
      AppLogger.warning('Sync remove watchlist failed: $e');
    }
  }
}
