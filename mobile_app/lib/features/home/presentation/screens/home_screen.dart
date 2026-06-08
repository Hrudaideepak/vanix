import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/vanix_image.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../providers/home_provider.dart';
import '../../../movies/models/content_model.dart';
import '../../../profile/providers/profile_provider.dart';

class HomeScreen extends StatefulWidget {
  final String? filterType;
  const HomeScreen({super.key, this.filterType});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch home screen shelves on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final activeProfile = profileProvider.activeProfile;
    final isKids = activeProfile?.isKids ?? false;

    final filteredBanners = widget.filterType == null
        ? homeProvider.featuredBanners
        : homeProvider.featuredBanners
            .where((m) => m.type == widget.filterType)
            .toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isKids ? AppTheme.kidsBackgroundGradient : AppTheme.backgroundGradient,
        ),
        child: homeProvider.isLoading
            ? _buildLoader()
            : RefreshIndicator(
                color: AppTheme.royalPurple,
                backgroundColor: AppTheme.cardGrey,
                onRefresh: () => homeProvider.fetchHomeScreen(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 110), // Room for bottom nav bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Brand Bar
                      _buildHeaderAppBar(activeProfile),
                      
                      // Hero Banner Carousel
                      if (filteredBanners.isNotEmpty)
                        _buildHeroCarousel(filteredBanners),
                      
                      const SizedBox(height: 28),

                      // Continue Watching Row
                      _buildFilteredShelf(
                        title: 'Continue Watching',
                        items: homeProvider.continueWatching,
                        builder: _buildContinueWatchingRow,
                      ),

                      // Trending Now Row
                      _buildFilteredShelf(
                        title: isKids ? 'Fun & Trending' : 'Trending Now',
                        items: homeProvider.trendingNow,
                        builder: _buildMovieRow,
                      ),

                      // Recommended For You Row
                      _buildFilteredShelf(
                        title: 'Recommended For You',
                        items: homeProvider.recommended,
                        builder: _buildMovieRow,
                      ),

                      // Because You Watched Row
                      _buildFilteredShelf(
                        title: homeProvider.becauseYouWatchedTitle,
                        items: homeProvider.becauseYouWatched,
                        builder: _buildMovieRow,
                      ),

                      // Latest Releases Row
                      _buildFilteredShelf(
                        title: 'Latest Releases',
                        items: homeProvider.latestReleases,
                        builder: _buildMovieRow,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderAppBar(dynamic activeProfile) {
    final isKids = activeProfile?.isKids ?? false;
    final profileName = activeProfile?.name ?? 'Guest';
    final avatarUrl = activeProfile?.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=Primary';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'VANIX',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            foreground: Paint()
                              ..shader = (isKids
                                      ? const LinearGradient(colors: [Colors.orangeAccent, Colors.pinkAccent])
                                      : AppTheme.premiumGradient)
                                  .createShader(
                                const Rect.fromLTWH(0.0, 0.0, 150.0, 30.0),
                              ),
                          ),
                    ),
                    if (isKids) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.orangeAccent]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'KIDS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isKids) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Hey $profileName! Ready for fun?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppTheme.softWhite),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Switch profile helper
                    Navigator.pushNamed(context, '/profiles');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isKids ? Colors.pinkAccent : AppTheme.royalPurple,
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCarousel(List<ContentModel> banners) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.48,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: banners.map((movie) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/movie-details',
                arguments: {'id': movie.id, 'type': movie.type},
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop Image
                      VanixImage(imageUrl: movie.bannerUrl),
                      // Premium Dark Overlay Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                              Colors.black.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Movie Data Panel
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (movie.isPremium)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                            Text(
                              movie.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.softWhite,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              movie.genres.join('  •  '),
                              style: TextStyle(
                                color: AppTheme.silverAccent.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Quick Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.softWhite,
                                    foregroundColor: AppTheme.deepBlack,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.play_arrow, size: 20),
                                  label: const Text('Play Now', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                const SizedBox(width: 12),
                                const GlassCard(
                                  borderRadius: 8,
                                  opacity: 0.15,
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.info_outline, color: AppTheme.softWhite, size: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildShelfHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.softWhite,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'See All',
            style: TextStyle(
              color: AppTheme.royalPurple.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingRow(List<ContentModel> movies) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/player',
              arguments: {
                'videoUrl': movie.videoUrl,
                'title': movie.title,
                'contentId': movie.id,
                'startOffset': (movie.progress * 60 * 100).toInt(), // Simulated progress offset
              },
            ),
            child: Container(
              width: 190,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VanixImage(imageUrl: movie.thumbnailUrl),
                    // Glass filter play icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        child: const Icon(Icons.play_arrow, color: AppTheme.softWhite, size: 24),
                      ),
                    ),
                    // Bottom progress indicator
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: movie.progress,
                              minHeight: 3,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.royalPurple),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieRow(List<ContentModel> movies) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/movie-details',
              arguments: {'id': movie.id, 'type': movie.type},
            ),
            child: Container(
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VanixImage(imageUrl: movie.thumbnailUrl),
                    // Glass header info bubble
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              movie.rating.toString(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (movie.isPremium)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.workspace_premium, size: 10, color: Colors.black),
                        ),
                      ),
                    // Title details container
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(
              onPlay: (controller) => controller.reverse(), // Simple micro-hover scale effect on click trigger
            ).scaleXY(
                  begin: 1.0,
                  end: 1.05,
                  duration: 200.ms,
                  curve: Curves.easeOut,
                ),
          );
        },
      ),
    );
  }

  Widget _buildLoader() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 60),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(width: 100, height: 28),
              Row(
                children: [
                  ShimmerLoading(width: 32, height: 32),
                  SizedBox(width: 12),
                  ShimmerLoading(width: 32, height: 32),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerLoading(width: double.infinity, height: 320, borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(width: 150, height: 20),
              ShimmerLoading(width: 50, height: 16),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (c, i) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: ShimmerLoading(width: 130, height: 180, borderRadius: BorderRadius.all(Radius.circular(14))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilteredShelf({
    required String title,
    required List<ContentModel> items,
    required Widget Function(List<ContentModel>) builder,
  }) {
    final filtered = widget.filterType == null
        ? items
        : items.where((m) => m.type == widget.filterType).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShelfHeader(title),
        builder(filtered),
        const SizedBox(height: 24),
      ],
    );
  }
}
