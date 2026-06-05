import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/vanix_image.dart';
import '../../providers/movie_provider.dart';
import '../../../watchlist/providers/watchlist_provider.dart';
import '../../../downloads/providers/download_provider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String contentId;
  final String contentType;

  const MovieDetailsScreen({
    super.key,
    required this.contentId,
    required this.contentType,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false)
          .fetchContentDetails(widget.contentId, widget.contentType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    final downloadProvider = Provider.of<DownloadProvider>(context);

    final movie = movieProvider.selectedContent;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: movieProvider.isLoading || movie == null
            ? _buildLoader()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Parallax Banner Image Header
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.45,
                    pinned: true,
                    stretch: true,
                    backgroundColor: AppTheme.deepBlack,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.softWhite),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          VanixImage(imageUrl: movie.bannerUrl),
                          // Dark gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                  AppTheme.deepBlack,
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Detail Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Premium Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.softWhite,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (movie.isPremium)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.workspace_premium, color: Colors.black, size: 16),
                                ),
                            ],
                          ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 12),

                          // Metadata row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.black, size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      movie.rating.toString(),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                '${movie.releaseYear}',
                                style: const TextStyle(color: AppTheme.silverAccent, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                movie.duration,
                                style: const TextStyle(color: AppTheme.silverAccent, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.silverAccent.withValues(alpha: 0.5)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Ultra 4K',
                                  style: TextStyle(color: AppTheme.silverAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                          const SizedBox(height: 24),

                          // Core Action Buttons (Play / Download / Watchlist)
                          Row(
                            children: [
                              // Play Button
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.royalPurple,
                                    foregroundColor: AppTheme.softWhite,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 8,
                                    shadowColor: AppTheme.royalPurple.withValues(alpha: 0.3),
                                  ),
                                  icon: const Icon(Icons.play_arrow, size: 24),
                                  label: const Text('Play Stream', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                              ),
                              const SizedBox(width: 12),
                              // Watchlist Toggle
                              Expanded(
                                child: _buildActionButton(
                                  icon: watchlistProvider.isInWatchlist(movie.id) ? Icons.bookmark : Icons.bookmark_border,
                                  color: watchlistProvider.isInWatchlist(movie.id) ? AppTheme.royalPurple : AppTheme.softWhite,
                                  onTap: () {
                                    if (watchlistProvider.isInWatchlist(movie.id)) {
                                      watchlistProvider.removeFromWatchlist(movie.id);
                                    } else {
                                      watchlistProvider.addToWatchlist(movie);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Download Toggle
                              Expanded(
                                child: _buildActionButton(
                                  icon: downloadProvider.isDownloaded(movie.id)
                                      ? Icons.download_done
                                      : (downloadProvider.isDownloading(movie.id) ? Icons.downloading : Icons.download),
                                  color: downloadProvider.isDownloaded(movie.id) ? AppTheme.electricBlue : AppTheme.softWhite,
                                  onTap: () {
                                    if (downloadProvider.isDownloaded(movie.id)) {
                                      downloadProvider.removeDownload(movie.id);
                                    } else {
                                      downloadProvider.startDownload(movie);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                          const SizedBox(height: 28),

                          // Description Synopsis
                          const Text(
                            'Synopsis',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.softWhite),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.description,
                            style: TextStyle(
                              color: AppTheme.silverAccent.withValues(alpha: 0.8),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                          const SizedBox(height: 24),

                          // Cast members
                          if (movie.cast.isNotEmpty) ...[
                            const Text(
                              'Cast',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.softWhite),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: movie.cast.length,
                                itemBuilder: (context, index) {
                                  final actor = movie.cast[index];
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 14),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundImage: NetworkImage('https://api.dicebear.com/7.x/adventurer/png?seed=$actor'),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          actor,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, color: AppTheme.silverAccent),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Suggested recommendations row
                          if (movieProvider.suggestedContent.isNotEmpty) ...[
                            const Text(
                              'Suggested Content',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.softWhite),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: movieProvider.suggestedContent.length,
                              itemBuilder: (context, index) {
                                final suggested = movieProvider.suggestedContent[index];
                                return GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(
                                    context,
                                    '/movie-details',
                                    arguments: {'id': suggested.id, 'type': suggested.type},
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: VanixImage(imageUrl: suggested.thumbnailUrl),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 10,
        opacity: 0.1,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.royalPurple),
    );
  }
}
