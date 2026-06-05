import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_client.dart';

class PlaybackProvider extends ChangeNotifier {
  PlaybackProvider();

  void updateAuth(String? token) {}

  Future<void> syncWatchProgress({
    required String contentId,
    required int progressSeconds,
    required int durationSeconds,
    String? episodeId,
  }) async {
    final progressPercentage = durationSeconds > 0 ? (progressSeconds / durationSeconds) : 0.0;
    AppLogger.debug('Sync progress: $contentId -> $progressSeconds / $durationSeconds sec (${(progressPercentage * 100).toStringAsFixed(1)}%)');

    try {
      final response = await ApiClient.instance.post('/history', body: {
        'movieId': contentId,
        'episodeId': episodeId,
        'progress': progressPercentage,
        'watchedTime': progressSeconds,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        AppLogger.warning('Watch progress sync failed: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.warning('Watch progress sync failed: $e.');
    }
  }

  Future<int> getSavedWatchOffset(String contentId, {String? episodeId}) async {
    try {
      final response = await ApiClient.instance.get('/history?movieId=$contentId');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final historyItem = decoded['data'];
        if (historyItem != null && historyItem['watchedTime'] != null) {
          return historyItem['watchedTime'] as int;
        }
      }
    } catch (_) {}
    return 0;
  }
}
