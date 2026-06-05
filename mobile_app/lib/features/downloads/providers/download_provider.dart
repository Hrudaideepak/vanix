import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../movies/models/content_model.dart';

class DownloadProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  List<ContentModel> _downloadedItems = [];
  final Map<String, double> _downloadProgress = {}; // contentId -> progress (0.0 to 1.0)
  final Map<String, String> _downloadStatus = {}; // contentId -> 'downloading' | 'paused' | 'completed'
  final Map<String, DateTime> _downloadDates = {}; // contentId -> download completion date
  final Map<String, Timer> _activeTimers = {};

  DownloadProvider({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences {
    _loadDownloadedItems();
    _checkExpiry();
  }

  List<ContentModel> get downloadedItems => _downloadedItems;
  Map<String, double> get downloadProgress => _downloadProgress;
  Map<String, String> get downloadStatus => _downloadStatus;

  void updateAuth(String? token) {
  }

  bool isDownloaded(String contentId) {
    return _downloadedItems.any((item) => item.id == contentId);
  }

  bool isDownloading(String contentId) {
    return _downloadStatus[contentId] == 'downloading';
  }

  bool isPaused(String contentId) {
    return _downloadStatus[contentId] == 'paused';
  }

  double getProgress(String contentId) {
    return _downloadProgress[contentId] ?? 0.0;
  }

  void _loadDownloadedItems() {
    final list = _prefs.getStringList(AppConstants.keyOfflineDownloads) ?? [];
    final datesJson = _prefs.getString('download_dates_meta') ?? '{}';
    
    try {
      _downloadedItems = list
          .map((item) => ContentModel.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
          
      final Map<String, dynamic> decodedDates = jsonDecode(datesJson);
      decodedDates.forEach((key, val) {
        _downloadDates[key] = DateTime.parse(val);
        _downloadStatus[key] = 'completed';
      });
      AppLogger.info('Loaded ${_downloadedItems.length} offline downloads.');
    } catch (e) {
      AppLogger.error('Failed to parse offline downloads: $e');
    }
  }

  void startDownload(ContentModel movie) {
    if (isDownloaded(movie.id) && !isPaused(movie.id)) return;

    _downloadProgress[movie.id] = _downloadProgress[movie.id] ?? 0.0;
    _downloadStatus[movie.id] = 'downloading';
    notifyListeners();

    _runDownloadTimer(movie);
  }

  void pauseDownload(String contentId) {
    if (_activeTimers.containsKey(contentId)) {
      _activeTimers[contentId]?.cancel();
      _activeTimers.remove(contentId);
      _downloadStatus[contentId] = 'paused';
      notifyListeners();
      AppLogger.info('Download paused: $contentId');
    }
  }

  void resumeDownload(ContentModel movie) {
    if (_downloadStatus[movie.id] == 'paused') {
      _downloadStatus[movie.id] = 'downloading';
      notifyListeners();
      _runDownloadTimer(movie);
      AppLogger.info('Download resumed: ${movie.title}');
    }
  }

  void _runDownloadTimer(ContentModel movie) {
    const interval = Duration(milliseconds: 350);
    _activeTimers[movie.id] = Timer.periodic(interval, (timer) {
      final currentProgress = _downloadProgress[movie.id] ?? 0.0;
      if (currentProgress >= 1.0) {
        timer.cancel();
        _activeTimers.remove(movie.id);
        _downloadProgress.remove(movie.id);
        _completeDownload(movie);
      } else {
        _downloadProgress[movie.id] = currentProgress + 0.05;
        notifyListeners();
      }
    });
  }

  void _completeDownload(ContentModel movie) async {
    _downloadedItems.add(movie);
    _downloadStatus[movie.id] = 'completed';
    _downloadDates[movie.id] = DateTime.now();
    notifyListeners();

    final stringList = _downloadedItems.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(AppConstants.keyOfflineDownloads, stringList);
    
    // Save dates metadata
    final Map<String, String> datesMap = {};
    _downloadDates.forEach((key, val) => datesMap[key] = val.toIso8601String());
    await _prefs.setString('download_dates_meta', jsonEncode(datesMap));
    
    AppLogger.info('Download complete: ${movie.title}');
  }

  Future<void> removeDownload(String contentId) async {
    if (_activeTimers.containsKey(contentId)) {
      _activeTimers[contentId]?.cancel();
      _activeTimers.remove(contentId);
      _downloadProgress.remove(contentId);
    }

    _downloadedItems.removeWhere((item) => item.id == contentId);
    _downloadStatus.remove(contentId);
    _downloadDates.remove(contentId);
    notifyListeners();

    final stringList = _downloadedItems.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(AppConstants.keyOfflineDownloads, stringList);
    
    final Map<String, String> datesMap = {};
    _downloadDates.forEach((key, val) => datesMap[key] = val.toIso8601String());
    await _prefs.setString('download_dates_meta', jsonEncode(datesMap));
    
    AppLogger.info('Deleted download: $contentId');
  }

  /// Automatically remove downloads older than 7 days
  void _checkExpiry() async {
    final now = DateTime.now();
    final List<String> expiredIds = [];

    _downloadDates.forEach((key, date) {
      final diff = now.difference(date).inDays;
      if (diff >= 7) {
        expiredIds.add(key);
      }
    });

    if (expiredIds.isNotEmpty) {
      AppLogger.info('Removing ${expiredIds.length} expired offline downloads.');
      for (var id in expiredIds) {
        await removeDownload(id);
      }
    }
  }

  @override
  void dispose() {
    for (var timer in _activeTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
