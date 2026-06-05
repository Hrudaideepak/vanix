import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/vanix_image.dart';
import '../../providers/watchlist_provider.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WatchlistProvider>(context, listen: false).fetchWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    final items = watchlistProvider.watchlistItems;

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
                  'My Watchlist',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.softWhite),
                ),
              ),

              // Watchlist List
              Expanded(
                child: watchlistProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.royalPurple))
                    : items.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final movie = items[index];
                              return Dismissible(
                                key: Key(movie.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorRed.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete_outline, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  watchlistProvider.removeFromWatchlist(movie.id);
                                },
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/movie-details',
                                    arguments: {'id': movie.id, 'type': movie.type},
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(12),
                                      opacity: 0.05,
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: SizedBox(
                                              width: 70,
                                              height: 100,
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
                                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.softWhite),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  movie.genres.join(' • '),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 11, color: AppTheme.silverAccent.withValues(alpha: 0.6)),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, color: Colors.amber, size: 12),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      movie.rating.toString(),
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Play Action icon
                                          IconButton(
                                            icon: const Icon(Icons.play_circle_fill, color: AppTheme.royalPurple, size: 36),
                                            onPressed: () => Navigator.pushNamed(
                                              context,
                                              '/player',
                                              arguments: {
                                                'videoUrl': movie.videoUrl,
                                                'title': movie.title,
                                                'contentId': movie.id,
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              )
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
          Icon(Icons.bookmark_outline, size: 64, color: AppTheme.silverAccent.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty.',
            style: TextStyle(color: AppTheme.silverAccent.withValues(alpha: 0.5), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
