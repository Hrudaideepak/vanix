import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../home/providers/home_provider.dart';
import '../../../movies/models/content_model.dart';
import '../../../watchlist/providers/watchlist_provider.dart';

// ---------------------------------------------------------------------------
// TrailersFeedScreen — Vertical reel feed of movie/show trailers & teasers
// Design: DESIGN.md Void-and-Neon cyberpunk aesthetic
// ---------------------------------------------------------------------------

class TrailersFeedScreen extends StatefulWidget {
  const TrailersFeedScreen({super.key});

  @override
  State<TrailersFeedScreen> createState() => _TrailersFeedScreenState();
}

class _TrailersFeedScreenState extends State<TrailersFeedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _initialized = false;

  // Curated fallback trailer list (used when HomeProvider has no content)
  static final List<ContentModel> _fallbackTrailers = [
    ContentModel(
      id: 'tr_1',
      title: 'Nebula Genesis',
      description:
          'A rogue squad of elite pilots investigates a silent signal from the core of the nebula, discovering the secret of human origin.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=800&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?w=1200&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      trailerUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      type: 'movie',
      rating: 8.9,
      releaseYear: 2024,
      duration: '2h 15m',
      genres: ['Sci-Fi', 'Thriller'],
      isPremium: true,
    ),
    ContentModel(
      id: 'tr_2',
      title: 'Shadow Sector',
      description:
          'An elite cyberpunk operative is blackmailed into executing the heist of the century inside a fortified megacity.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=800&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1200&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      trailerUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      type: 'movie',
      rating: 8.4,
      releaseYear: 2024,
      duration: '1h 58m',
      genres: ['Cyberpunk', 'Action'],
      isPremium: true,
    ),
    ContentModel(
      id: 'tr_3',
      title: 'Inferno Protocol',
      description:
          'When a classified weapon disappears from a black-site facility, one operative must race against extinction.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      trailerUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      type: 'movie',
      rating: 8.7,
      releaseYear: 2025,
      duration: '2h 02m',
      genres: ['Action', 'Thriller'],
      isPremium: false,
    ),
    ContentModel(
      id: 'tr_4',
      title: 'Ocean Deep',
      description:
          'An exploration team investigating the Mariana Trench encounters a prehistoric aquatic leviathan buried for millennia.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=800&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=1200&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      trailerUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      type: 'movie',
      rating: 8.2,
      releaseYear: 2023,
      duration: '2h 05m',
      genres: ['Adventure', 'Sci-Fi'],
      isPremium: true,
    ),
    ContentModel(
      id: 'tr_5',
      title: 'Ragnarok Rising',
      description:
          'Nordic gods assemble across realms to protect Midgard from the age of fire and inevitable annihilation.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      trailerUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      type: 'movie',
      rating: 9.1,
      releaseYear: 2024,
      duration: '2h 45m',
      genres: ['Fantasy', 'Action'],
      isPremium: true,
    ),
  ];

  List<ContentModel> _trailers = [];

  @override
  void initState() {
    super.initState();
    // Force portrait for this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _buildTrailerList();
    }
  }

  void _buildTrailerList() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final allContent = [
      ...homeProvider.trendingNow,
      ...homeProvider.recommended,
      ...homeProvider.featuredBanners,
    ];

    // Filter content that has either trailerUrl or videoUrl
    final filtered = allContent
        .where((c) => c.trailerUrl.isNotEmpty || c.videoUrl.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      _trailers = filtered.isNotEmpty ? filtered : _fallbackTrailers;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_trailers.isEmpty) {
      return const _TrailerLoadingPlaceholder();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Global grid overlay from DESIGN.md
          const _GridOverlay(),

          // Main vertical reel feed
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _trailers.length,
            itemBuilder: (context, index) {
              return _TrailerReelPage(
                content: _trailers[index],
                isActive: _currentPage == index,
              );
            },
          ),

          // Top HUD: Logo + Tab Label
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // VANIX logo
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                    ).createShader(bounds),
                    child: const Text(
                      'VANIX',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Label chip — Space Mono, sharp corner, semi-red bg
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFF0000), // rgba(255,0,0,0.1)
                      border:
                          Border.all(color: const Color(0x33FF0000), width: 1),
                    ),
                    child: const Text(
                      'TRAILERS',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                        color: Color(0xFFFF0000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Page indicator dots — right side vertical
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_trailers.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    width: 3,
                    height: isActive ? 24 : 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFF0000)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual Trailer Reel Page
// ---------------------------------------------------------------------------

class _TrailerReelPage extends StatefulWidget {
  final ContentModel content;
  final bool isActive;

  const _TrailerReelPage({required this.content, required this.isActive});

  @override
  State<_TrailerReelPage> createState() => _TrailerReelPageState();
}

class _TrailerReelPageState extends State<_TrailerReelPage>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isMuted = true;
  bool _showMuteIcon = false;
  Timer? _muteIconTimer;
  late AnimationController _muteAnim;

  String get _videoUrl => widget.content.trailerUrl.isNotEmpty
      ? widget.content.trailerUrl
      : widget.content.videoUrl;

  @override
  void initState() {
    super.initState();
    _muteAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.isActive) {
      _initPlayer();
    }
  }

  @override
  void didUpdateWidget(_TrailerReelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initPlayer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller?.pause();
    }
  }

  Future<void> _initPlayer() async {
    if (_videoUrl.isEmpty) return;

    // Dispose existing controller before creating new one
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      if (mounted) setState(() => _isInitialized = false);
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(_isMuted ? 0.0 : 1.0);
      if (widget.isActive) {
        controller.play();
      }
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
      } else {
        controller.dispose();
      }
    } catch (_) {
      controller.dispose();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
      _showMuteIcon = true;
    });

    _muteAnim.forward(from: 0);
    _muteIconTimer?.cancel();
    _muteIconTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showMuteIcon = false);
    });
  }

  @override
  void dispose() {
    _muteIconTimer?.cancel();
    _muteAnim.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleMute,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video Layer ──────────────────────────────────────────────
            if (_isInitialized && _controller != null)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              // Thumbnail while loading
              _ThumbnailFallback(imageUrl: widget.content.thumbnailUrl),

            // ── Gradient Vignette ────────────────────────────────────────
            const _BottomVignette(),

            // ── Progress Bar (top edge) ──────────────────────────────────
            if (_isInitialized && _controller != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _VideoProgressLine(controller: _controller!),
              ),

            // ── Content Info (bottom-left) ───────────────────────────────
            Positioned(
              left: 16,
              right: 72,
              bottom: 80,
              child: _ContentInfo(content: widget.content),
            ),

            // ── Action Sidebar (right) ───────────────────────────────────
            Positioned(
              right: 12,
              bottom: 120,
              child: _ActionSidebar(content: widget.content),
            ),

            // ── Mute Icon Overlay ────────────────────────────────────────
            if (_showMuteIcon)
              Center(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(parent: _muteAnim, curve: Curves.easeOut),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      border:
                          Border.all(color: const Color(0x33FF0000), width: 1),
                    ),
                    child: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),

            // ── "NEW" badge ──────────────────────────────────────────────
            Positioned(
              top: 80,
              left: 16,
              child: _BadgeChip(label: widget.content.type.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content Info Panel (title, genres, description)
// ---------------------------------------------------------------------------

class _ContentInfo extends StatelessWidget {
  final ContentModel content;
  const _ContentInfo({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title — Space Grotesk bold
        Text(
          content.title.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.1,
            shadows: [Shadow(color: Colors.black, blurRadius: 8)],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),

        // Meta row: rating + year + duration
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFFF0000), size: 13),
            const SizedBox(width: 4),
            Text(
              content.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFF0000),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${content.releaseYear}  ·  ${content.duration}',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Genre chips
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: content.genres.take(3).map((g) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x1AFF0000),
                border: Border.all(color: const Color(0x33FF0000), width: 1),
              ),
              child: Text(
                g.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFF0000),
                  letterSpacing: 1.5,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Description — Geist body
        Text(
          content.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),

        // WATCH FULL CTA — solid red, sharp corners (0px), black text
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/movie-details',
              arguments: {
                'id': content.id,
                'type': content.type,
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFF0000), // DESIGN.md primary red
              // borderRadius: BorderRadius.zero — sharp (0px) per DESIGN.md
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, color: Colors.black, size: 16),
                SizedBox(width: 6),
                Text(
                  'WATCH FULL',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action Sidebar (Like, Watchlist, Share)
// ---------------------------------------------------------------------------

class _ActionSidebar extends StatefulWidget {
  final ContentModel content;
  const _ActionSidebar({required this.content});

  @override
  State<_ActionSidebar> createState() => _ActionSidebarState();
}

class _ActionSidebarState extends State<_ActionSidebar> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final watchlistProvider =
        Provider.of<WatchlistProvider>(context, listen: false);
    final isInWatchlist = watchlistProvider.isInWatchlist(widget.content.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like
        _SidebarButton(
          icon: _liked ? Icons.favorite : Icons.favorite_border,
          label: 'LIKE',
          isActive: _liked,
          onTap: () => setState(() => _liked = !_liked),
        ),
        const SizedBox(height: 20),

        // Watchlist
        _SidebarButton(
          icon: isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
          label: 'SAVE',
          isActive: isInWatchlist,
          onTap: () {
            if (isInWatchlist) {
              watchlistProvider.removeFromWatchlist(widget.content.id);
            } else {
              watchlistProvider.addToWatchlist(widget.content);
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 20),

        // Share
        _SidebarButton(
          icon: Icons.share_outlined,
          label: 'SHARE',
          isActive: false,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.black,
                content: Row(
                  children: [
                    const Icon(Icons.share, color: Color(0xFFFF0000), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'SHARING "${widget.content.title.toUpperCase()}"',
                      style: const TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 11,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                margin: const EdgeInsets.all(16),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFF0000)
                  : Colors.black.withValues(alpha: 0.5),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFFF0000)
                    : Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              // Sharp — 0px corners per DESIGN.md
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 8,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Video progress scanline bar (top of screen)
// ---------------------------------------------------------------------------

class _VideoProgressLine extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoProgressLine({required this.controller});

  @override
  State<_VideoProgressLine> createState() => _VideoProgressLineState();
}

class _VideoProgressLineState extends State<_VideoProgressLine> {
  late Timer _timer;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      final pos = widget.controller.value.position.inMilliseconds;
      final dur = widget.controller.value.duration.inMilliseconds;
      if (dur > 0) setState(() => _progress = pos / dur);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: Stack(
        children: [
          // Background track — 10% red
          Container(color: const Color(0x1AFF0000)),
          // Active fill — full red
          FractionallySizedBox(
            widthFactor: _progress.clamp(0.0, 1.0),
            child: Container(color: const Color(0xFFFF0000)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom vignette gradient
// ---------------------------------------------------------------------------

class _BottomVignette extends StatelessWidget {
  const _BottomVignette();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.45, 0.78, 1.0],
            colors: [
              Colors.transparent,
              Color(0xCC000000),
              Colors.black,
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Thumbnail fallback while video loads
// ---------------------------------------------------------------------------

class _ThumbnailFallback extends StatelessWidget {
  final String imageUrl;
  const _ThumbnailFallback({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF0A0A0A)),
          )
        else
          Container(color: const Color(0xFF0A0A0A)),
        // Loading pulse overlay
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              border: Border.all(color: const Color(0x33FF0000), width: 1),
            ),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF0000),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Badge chip (MOVIE / SERIES / TEASER)
// ---------------------------------------------------------------------------

class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x1AFF0000),
        border: Border.all(color: const Color(0x33FF0000), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 9,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: Color(0xFFFF0000),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Global red grid overlay (DESIGN.md visual texture)
// ---------------------------------------------------------------------------

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _GridPainter()),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08FF0000) // rgba(255,0,0,0.03) ≈ 0x08
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Loading placeholder while trailers are initialising
// ---------------------------------------------------------------------------

class _TrailerLoadingPlaceholder extends StatelessWidget {
  const _TrailerLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF0000),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'LOADING TRAILERS',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
