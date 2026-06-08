import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../movies/models/content_model.dart';

class DownloadProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  List<ContentModel> _downloadedItems = [];
  final Map<String, double> _downloadProgress = {}; // contentId -> progress (0.0 to 1.0)
  final Map<String, String> _downloadStatus = {}; // contentId -> 'downloading' | 'paused' | 'completed' | 'failed'
  final Map<String, DateTime> _downloadDates = {}; // contentId -> download completion date
  final Map<String, StreamSubscription> _activeSubscriptions = {};
  final Map<String, http.Client> _activeClients = {};

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

  Future<void> startDownload(ContentModel movie) async {
    if (isDownloaded(movie.id) && _downloadStatus[movie.id] == 'completed') return;

    _downloadProgress[movie.id] = _downloadProgress[movie.id] ?? 0.0;
    _downloadStatus[movie.id] = 'downloading';
    notifyListeners();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Check for playable URL - default to a standard sample MP4 for testing if URL is HLS/m3u8
      String urlString = movie.videoUrl;
      if (!urlString.endsWith('.mp4')) {
        urlString = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      }

      final uri = Uri.parse(urlString);
      final file = File('${downloadsDir.path}/${movie.id}.mp4');

      
      int existingBytes = 0;
      if (await file.exists() && _downloadProgress[movie.id]! > 0.0) {
        existingBytes = await file.length();
      }

      final client = http.Client();
      _activeClients[movie.id] = client;

      final request = http.Request('GET', uri);

      
      final request = http.Request('GET', uri);
      
      if (existingBytes > 0) {
        request.headers['Range'] = 'bytes=$existingBytes-';
      }

      final response = await client.send(request);

      // HTTP 206 means Partial Content (supporting pause/resume)
      // If server doesn't support Range and sends 200, we overwrite instead of append
      final bool isPartial = response.statusCode == 206;
      final bool append = isPartial && existingBytes > 0;
      final int startBytes = append ? existingBytes : 0;

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw HttpException('Server returned error status code: ${response.statusCode}');
      }

      final totalBytes = (response.contentLength ?? 0) + startBytes;
      final fileSink = file.openWrite(mode: append ? FileMode.append : FileMode.write);

      int bytesDownloaded = startBytes;

      final subscription = response.stream.listen(
        (chunk) {
          fileSink.add(chunk);
          bytesDownloaded += chunk.length;
          if (totalBytes > 0) {
            _downloadProgress[movie.id] = bytesDownloaded / totalBytes;
            notifyListeners();
          }
        },
        onDone: () async {
          await fileSink.close();
          _activeSubscriptions.remove(movie.id);
          _activeClients.remove(movie.id);
          client.close();
          _downloadProgress.remove(movie.id);

          // Build a new model pointing to the local file path instead of network url
          final downloadedMovie = ContentModel(
            id: movie.id,
            title: movie.title,
            description: movie.description,
            thumbnailUrl: movie.thumbnailUrl,
            bannerUrl: movie.bannerUrl,
            videoUrl: file.path,
            type: movie.type,
            rating: movie.rating,
            releaseYear: movie.releaseYear,
            duration: movie.duration,
            genres: movie.genres,
            isPremium: movie.isPremium,
            progress: movie.progress,
            cast: movie.cast,
            crew: movie.crew,
          );

          _completeDownload(downloadedMovie);
        },
        onError: (err) async {
          await fileSink.close();
          _activeSubscriptions.remove(movie.id);
          _activeClients.remove(movie.id);
          client.close();
          AppLogger.error('Download stream error for ${movie.title}: $err');
          _downloadStatus[movie.id] = 'failed';
          notifyListeners();
        },
        cancelOnError: true,
      );

      _activeSubscriptions[movie.id] = subscription;
    } catch (e) {
      AppLogger.error('Failed to initiate download for ${movie.title}: $e');
      _downloadStatus[movie.id] = 'failed';
      _downloadProgress.remove(movie.id);
      _activeClients[movie.id]?.close();
      _activeClients.remove(movie.id);
      notifyListeners();
    }
  }

  void pauseDownload(String contentId) {
    if (_activeSubscriptions.containsKey(contentId)) {
      _activeSubscriptions[contentId]?.cancel();
      _activeSubscriptions.remove(contentId);
    }
    if (_activeClients.containsKey(contentId)) {
      _activeClients[contentId]?.close();
      _activeClients.remove(contentId);
    }
    _downloadStatus[contentId] = 'paused';
    notifyListeners();
    AppLogger.info('Download paused: $contentId');
  }

  void resumeDownload(ContentModel movie) {
    if (_downloadStatus[movie.id] == 'paused') {
      _downloadStatus[movie.id] = 'downloading';
      notifyListeners();
      startDownload(movie);
      AppLogger.info('Download resumed: ${movie.title}');
    }
  }

  void _completeDownload(ContentModel movie) async {
    // Check if already in list to avoid duplicates
    _downloadedItems.removeWhere((item) => item.id == movie.id);

    
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
    if (_activeSubscriptions.containsKey(contentId)) {
      _activeSubscriptions[contentId]?.cancel();
      _activeSubscriptions.remove(contentId);
    }
    if (_activeClients.containsKey(contentId)) {
      _activeClients[contentId]?.close();
      _activeClients.remove(contentId);
    }
    _downloadProgress.remove(contentId);

    // Delete local downloaded file
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/downloads/$contentId.mp4');
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Deleted local downloaded file: ${file.path}');
      }
    } catch (e) {
      AppLogger.error('Failed to delete offline file: $e');
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
    for (var sub in _activeSubscriptions.values) {
      sub.cancel();
    }
    for (var client in _activeClients.values) {
      client.close();
    }
    super.dispose();
  }
}
