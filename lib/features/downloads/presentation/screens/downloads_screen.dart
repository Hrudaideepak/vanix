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
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.softWhite),
                ),
              ),

              _buildStorageBreakdown(context),

              // Downloads Body
              Expanded(
                child: completedList.isEmpty && progressMap.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        children: [
                          // Active In-Progress Downloads
                          if (progressMap.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Downloading...',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.silverAccent),
                              ),
                            ),
                            ...progressMap.entries.map((entry) {
                              final contentId = entry.key;
                              final progress = entry.value;

                              // Simulated speed and remaining time for v2 polish
                              final speed =
                                  (4.8 + (contentId.hashCode % 4) * 0.6)
                                      .toStringAsFixed(1);
                              final remaining = progress > 0.95
                                  ? 'Finishing...'
                                  : '${((1.0 - progress) * 45).toInt() + 3}s left';

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  opacity: 0.08,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.downloading,
                                          color: AppTheme.royalPurple,
                                          size: 24),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Item: $contentId',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.softWhite,
                                                  fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '$speed MB/s • $remaining',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: AppTheme
                                                          .silverAccent
                                                          .withValues(
                                                              alpha: 0.5)),
                                                ),
                                                Text(
                                                  '${(progress * 100).toInt()}%',
                                                  style: const TextStyle(
                                                      color:
                                                          AppTheme.royalPurple,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 4,
                                              backgroundColor: Colors.white12,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                          Color>(
                                                      AppTheme.royalPurple),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.cancel_outlined,
                                            color: AppTheme.errorRed, size: 20),
                                        onPressed: () => downloadProvider
                                            .removeDownload(contentId),
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
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.silverAccent),
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
                                          child: VanixImage(
                                              imageUrl: movie.thumbnailUrl),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.softWhite,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              movie.duration,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.silverAccent
                                                      .withValues(alpha: 0.6)),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Available Offline',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Play Offline Button
                                      IconButton(
                                        icon: const Icon(
                                            Icons.play_arrow_outlined,
                                            color: AppTheme.softWhite),
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
                                        icon: const Icon(Icons.delete_outline,
                                            color: AppTheme.errorRed, size: 20),
                                        onPressed: () => downloadProvider
                                            .removeDownload(movie.id),
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
          Icon(Icons.download_done,
              size: 64, color: AppTheme.silverAccent.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            'No movies or shows downloaded yet.',
            style: TextStyle(
                color: AppTheme.silverAccent.withValues(alpha: 0.5),
                fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBreakdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Device Storage',
                style: TextStyle(
                  color: AppTheme.softWhite.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '45.8 GB Free of 64 GB',
                style: TextStyle(
                  color: AppTheme.silverAccent,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 12, // 1.2 GB (Vanix)
                    child: Container(color: AppTheme.royalPurple),
                  ),
                  Expanded(
                    flex: 124, // 12.4 GB (Other)
                    child: Container(color: Colors.white24),
                  ),
                  Expanded(
                    flex: 458, // 45.8 GB (Free)
                    child: Container(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLegendItem(AppTheme.royalPurple, 'Vanix (1.2 GB)'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.white24, 'Other (12.4 GB)'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.green, 'Free (45.8 GB)'),
            ],
          ),
          const Divider(color: Colors.white10, height: 28),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
              color: AppTheme.silverAccent,
              fontSize: 10,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
