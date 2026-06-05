import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/vanix_image.dart';
import '../../providers/download_provider.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadProvider = Provider.of<DownloadProvider>(context);
    final completedList = downloadProvider.downloadedItems;
    final progressMap = downloadProvider.downloadProgress;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'Offline Downloads',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.softWhite),
                ),
              ),

              // Downloads Body
              Expanded(
                child: completedList.isEmpty && progressMap.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        children: [
                          // Active In-Progress Downloads
                          if (progressMap.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Downloading...',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.silverAccent),
                              ),
                            ),
                            ...progressMap.entries.map((entry) {
                              final contentId = entry.key;
                              final progress = entry.value;
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  opacity: 0.08,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.downloading, color: AppTheme.royalPurple, size: 24),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Item: $contentId',
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.softWhite),
                                            ),
                                            const SizedBox(height: 8),
                                            LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 4,
                                              backgroundColor: Colors.white12,
                                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.royalPurple),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppTheme.royalPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                                      IconButton(
                                        icon: const Icon(Icons.cancel_outlined, color: AppTheme.errorRed, size: 20),
                                        onPressed: () => downloadProvider.removeDownload(contentId),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],

                          // Completed Offline List
                          if (completedList.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Completed',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.silverAccent),
                              ),
                            ),
                            ...completedList.map((movie) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  opacity: 0.05,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 60,
                                          height: 85,
                                          child: VanixImage(imageUrl: movie.thumbnailUrl),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.softWhite, fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              movie.duration,
                                              style: TextStyle(fontSize: 11, color: AppTheme.silverAccent.withValues(alpha: 0.6)),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Available Offline',
                                              style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Play Offline Button
                                      IconButton(
                                        icon: const Icon(Icons.play_arrow_outlined, color: AppTheme.softWhite),
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          '/player',
                                          arguments: {
                                            'videoUrl': movie.videoUrl,
                                            'title': movie.title,
                                            'contentId': movie.id,
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 20),
                                        onPressed: () => downloadProvider.removeDownload(movie.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ]
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_done, size: 64, color: AppTheme.silverAccent.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            'No movies or shows downloaded yet.',
            style: TextStyle(color: AppTheme.silverAccent.withValues(alpha: 0.5), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
