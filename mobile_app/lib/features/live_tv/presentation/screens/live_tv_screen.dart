import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/vanix_image.dart';

class LiveChannel {
  final String id;
  final String name;
  final String currentShow;
  final String nextShow;
  final String logoUrl;
  final String streamUrl;
  final String category;
  final double progress;

  LiveChannel({
    required this.id,
    required this.name,
    required this.currentShow,
    required this.nextShow,
    required this.logoUrl,
    required this.streamUrl,
    required this.category,
    required this.progress,
  });
}

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  final List<LiveChannel> _channels = [
    LiveChannel(
      id: 'ch_1',
      name: 'VANIX Action HD',
      currentShow: 'Tears of Steel: Cyber Heist',
      nextShow: 'Shadow Sector: Overdrive',
      logoUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=200&q=80',
      streamUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
      category: 'Movies',
      progress: 0.65,
    ),
    LiveChannel(
      id: 'ch_2',
      name: 'Cyberpunk Cinema',
      currentShow: 'Sintel: Legacy of Legends',
      nextShow: 'Nebula Genesis: Part 1',
      logoUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=200&q=80',
      streamUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
      category: 'Cyberpunk',
      progress: 0.42,
    ),
    LiveChannel(
      id: 'ch_3',
      name: 'Sci-Fi Broadcast',
      currentShow: 'Big Buck Bunny: Cosmic Tales',
      nextShow: 'Cosmology: Dark Matter',
      logoUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=200&q=80',
      streamUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', // Fallback MP4
      category: 'Sci-Fi',
      progress: 0.88,
    ),
    LiveChannel(
      id: 'ch_4',
      name: 'VANIX Pulse',
      currentShow: 'Music Video Marathon',
      nextShow: 'Late Night Talk: Tech Horizon',
      logoUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=200&q=80',
      streamUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      category: 'Entertainment',
      progress: 0.15,
    ),
  ];

  late LiveChannel _selectedChannel;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  // Live Chat Simulator
  final List<Map<String, String>> _messages = [
    {'user': 'Alex_99', 'text': 'This stream is amazing!'},
    {'user': 'NeonRider', 'text': 'Vibe check pass.'},
    {'user': 'SofiaTeal', 'text': 'Is this 1080p? Looks super crisp.'},
    {'user': 'Cosmic_Kid', 'text': 'Love Tears of Steel!'},
  ];
  final ScrollController _chatScrollController = ScrollController();
  Timer? _chatTimer;

  final List<String> _chatMockUsers = ['Viper_0', 'StarGazer', 'Hologram', 'TealSpark', 'CyberWolf', 'AtlasMax', 'LunaGlow', 'PixelEdge'];
  final List<String> _chatMockTexts = [
    'Wow, the UI is so clean!',
    'Loving the new Royal Teal aesthetic.',
    'Wait, next show is Nebula Genesis? I am staying for sure.',
    'Is the player supporting HLS multi-audio?',
    'This live stream works perfectly.',
    'VANIX has the best premium streams.',
    'Hype! 🔥🔥🔥',
    'Perfect layout, feels like Apple TV+.'
  ];

  @override
  void initState() {
    super.initState();
    _selectedChannel = _channels[0];
    _initializePlayer();
    _startLiveChatSimulator();
  }

  @override
  void dispose() {
    _chatTimer?.cancel();
    _chatScrollController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _startLiveChatSimulator() {
    _chatTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final random = DateTime.now().millisecondsSinceEpoch;
      final user = _chatMockUsers[random % _chatMockUsers.length];
      final text = _chatMockTexts[random % _chatMockTexts.length];
      
      setState(() {
        _messages.add({'user': user, 'text': text});
        if (_messages.length > 50) _messages.removeAt(0);
      });

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
    }
    if (_chewieController != null) {
      _chewieController!.dispose();
    }

    try {
      final isHls = _selectedChannel.streamUrl.contains('.m3u8');
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(_selectedChannel.streamUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        isLive: isHls,
        aspectRatio: 16 / 9,
        showControls: true,
        placeholder: Container(color: Colors.black),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.royalPurple,
          handleColor: AppTheme.royalPurple,
          bufferedColor: AppTheme.silverAccent.withValues(alpha: 0.3),
          backgroundColor: Colors.white24,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _switchChannel(LiveChannel channel) {
    if (channel.id == _selectedChannel.id) return;
    setState(() {
      _selectedChannel = channel;
    });
    _initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            const Text(
              'Live TV Arena',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppTheme.softWhite,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Top Area: Player + Live Chat
            Expanded(
              child: Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Player Container
                  Expanded(
                    flex: 3,
                    child: GlassCard(
                      opacity: 0.04,
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isLoading)
                              const CircularProgressIndicator(color: AppTheme.royalPurple)
                            else if (_hasError)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
                                  const SizedBox(height: 12),
                                  const Text('Failed to load live stream', style: TextStyle(color: AppTheme.softWhite)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.royalPurple),
                                    onPressed: _initializePlayer,
                                    child: const Text('Retry Stream'),
                                  )
                                ],
                              )
                            else
                              Chewie(controller: _chewieController!),
                            
                            // Live Badge overlay
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (isDesktop) const SizedBox(width: 20) else const SizedBox(height: 20),

                  // Live Chat Container
                  Expanded(
                    flex: 1,
                    child: GlassCard(
                      opacity: 0.06,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, color: AppTheme.royalPurple, size: 18),
                              const SizedBox(width: 8),
                              const Text('Live Stream Chat', style: TextStyle(color: AppTheme.softWhite, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                              )
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 24),
                          Expanded(
                            child: ListView.builder(
                              controller: _chatScrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${msg['user']}: ',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.electricBlue, fontSize: 13),
                                        ),
                                        TextSpan(
                                          text: msg['text']!,
                                          style: const TextStyle(color: AppTheme.softWhite, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Area: Channels List
            const Text(
              'Live Channel Guide',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.softWhite,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _channels.length,
                itemBuilder: (context, index) {
                  final ch = _channels[index];
                  final isSelected = ch.id == _selectedChannel.id;

                  return GestureDetector(
                    onTap: () => _switchChannel(ch),
                    child: Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 14),
                      child: GlassCard(
                        opacity: isSelected ? 0.15 : 0.04,
                        padding: const EdgeInsets.all(12),
                        color: isSelected ? AppTheme.royalPurple : null,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: VanixImage(imageUrl: ch.logoUrl),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ch.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppTheme.softWhite,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ch.currentShow,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : AppTheme.silverAccent.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: ch.progress,
                                    minHeight: 2.5,
                                    backgroundColor: isSelected ? Colors.white30 : Colors.white12,
                                    valueColor: AlwaysStoppedAnimation<Color>(isSelected ? Colors.white : AppTheme.royalPurple),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
