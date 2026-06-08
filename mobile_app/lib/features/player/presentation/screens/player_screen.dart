import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../providers/playback_provider.dart';

class SubtitleLine {
  final Duration start;
  final Duration end;
  final String text;
  SubtitleLine({required this.start, required this.end, required this.text});
}

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String contentId;
  final int startOffset;
  final String? episodeId;

  const PlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.contentId,
    this.startOffset = 0,
    this.episodeId,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  Timer? _progressTimer;

  // Swipe controls indicators
  double _volume = 0.5;
  double _brightness = 0.5;
  String? _gestureIndicator;

  // HLS stream metadata
  String _activeUrl = '';
  Map<String, dynamic> _resolutions = {};
  List<dynamic> _subtitleTracks = [];
  List<dynamic> _audioTracks = [];

  String _selectedQuality = 'Auto';
  Map<String, dynamic>? _selectedSubtitle;
  Map<String, dynamic>? _selectedAudio;

  List<SubtitleLine> _parsedSubtitles = [];
  String _currentSubtitleText = '';

  @override
  void initState() {
    super.initState();
    _activeUrl = widget.videoUrl;
    _setLandscapeOrientation();
    _fetchMediaDetails().then((_) {
      _initializePlayer(widget.startOffset);
    });
  }

  void _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restorePortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Future<void> _fetchMediaDetails() async {
    try {
      final response = await ApiClient.instance.get('/movie/${widget.contentId}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        if (data != null) {
          setState(() {
            _resolutions = data['resolutions'] ?? {};
            _subtitleTracks = data['subtitles'] ?? [];
            _audioTracks = data['audioTracks'] ?? [];
            
            // Set HLS base url if it exists
            if (data['hlsUrl'] != null && data['hlsUrl'].isNotEmpty) {
              _activeUrl = data['hlsUrl'];
            }
          });
        }
      }
    } catch (e) {
      AppLogger.warning('Could not fetch media tracks metadata: $e');
    }
  }

  Future<void> _initializePlayer(int startAtSeconds) async {
    try {
      if (_activeUrl.startsWith('http')) {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(_activeUrl));
      } else {
        final cleanPath = Uri.parse(_activeUrl).toFilePath();
        _videoPlayerController = VideoPlayerController.file(File(cleanPath));
      }
      await _videoPlayerController.initialize();

      _videoPlayerController.addListener(_subtitleListener);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        startAt: Duration(seconds: startAtSeconds),
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.royalPurple),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.royalPurple,
          handleColor: AppTheme.royalPurple,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white12,
        ),
      );

      _startProgressSync();
      setState(() {});
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _switchStream(String newUrl) async {
    if (_chewieController == null) return;
    
    final currentPos = _videoPlayerController.value.position.inSeconds;
    
    _progressTimer?.cancel();
    _videoPlayerController.removeListener(_subtitleListener);
    
    // Dispose current player
    await _videoPlayerController.dispose();
    _chewieController?.dispose();
    
    setState(() {
      _chewieController = null;
      _activeUrl = newUrl;
    });

    _initializePlayer(currentPos);
  }

  // SRT/VTT Subtitle parser
  List<SubtitleLine> _parseVtt(String vttData) {
    final List<SubtitleLine> lines = [];
    final RegExp regExp = RegExp(
      r'(\d{2}:\d{2}:\d{2}[\.,]\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2}[\.,]\d{3})\r?\n([\s\S]*?)(?=\r?\n\r?\n|\r?\n*$)',
      multiLine: true,
    );

    Duration parseTime(String timeStr) {
      final parts = timeStr.replaceAll(',', '.').split(':');
      final secondsParts = parts[2].split('.');
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(secondsParts[0]),
        milliseconds: int.parse(secondsParts[1]),
      );
    }

    final matches = regExp.allMatches(vttData);
    for (final match in matches) {
      try {
        final start = parseTime(match.group(1)!);
        final end = parseTime(match.group(2)!);
        final text = match.group(3)!.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        lines.add(SubtitleLine(start: start, end: end, text: text));
      } catch (_) {}
    }
    return lines;
  }

  Future<void> _loadSubtitleTrack(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        setState(() {
          _parsedSubtitles = _parseVtt(res.body);
        });
        AppLogger.info('Subtitles loaded: ${_parsedSubtitles.length} cues parsed');
      }
    } catch (e) {
      AppLogger.error('Failed loading subtitles track: $e');
    }
  }

  void _subtitleListener() {
    if (_parsedSubtitles.isEmpty) return;
    
    final pos = _videoPlayerController.value.position;
    final activeLine = _parsedSubtitles.firstWhere(
      (line) => pos >= line.start && pos <= line.end,
      orElse: () => SubtitleLine(start: Duration.zero, end: Duration.zero, text: ''),
    );

    if (_currentSubtitleText != activeLine.text) {
      setState(() {
        _currentSubtitleText = activeLine.text;
      });
    }
  }

  void _startProgressSync() {
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_videoPlayerController.value.isInitialized) {
        final position = _videoPlayerController.value.position.inSeconds;
        final duration = _videoPlayerController.value.duration.inSeconds;
        
        Provider.of<PlaybackProvider>(context, listen: false).syncWatchProgress(
          contentId: widget.contentId,
          progressSeconds: position,
          durationSeconds: duration,
          episodeId: widget.episodeId,
        );
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _videoPlayerController.removeListener(_subtitleListener);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _restorePortraitOrientation();
    super.dispose();
  }

  void _handleVerticalSwipe(DragUpdateDetails details, double screenWidth) {
    final isLeftSide = details.globalPosition.dx < (screenWidth / 2);
    final delta = -details.primaryDelta! / 200.0;

    setState(() {
      if (isLeftSide) {
        _brightness = (_brightness + delta).clamp(0.0, 1.0);
        _gestureIndicator = 'Brightness: ${(_brightness * 100).toInt()}%';
      } else {
        _volume = (_volume + delta).clamp(0.0, 1.0);
        _videoPlayerController.setVolume(_volume);
        _gestureIndicator = 'Volume: ${(_volume * 100).toInt()}%';
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _gestureIndicator = null;
        });
      }
    });
  }

  void _showSeekIndicator(String text) {
    setState(() {
      _gestureIndicator = text;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _gestureIndicator == text) {
        setState(() {
          _gestureIndicator = null;
        });
      }
    });
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double currentSpeed = _videoPlayerController.value.playbackSpeed;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Playback Configurations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.softWhite),
                  ),
                  const SizedBox(height: 20),

                  // Playback Speed Selector
                  const Text('Playback Speed', style: TextStyle(color: AppTheme.silverAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSettingsChip('0.5x', currentSpeed == 0.5, () {
                        _videoPlayerController.setPlaybackSpeed(0.5);
                        setModalState(() {});
                        Navigator.pop(context);
                      }),
                      _buildSettingsChip('1.0x (Normal)', currentSpeed == 1.0, () {
                        _videoPlayerController.setPlaybackSpeed(1.0);
                        setModalState(() {});
                        Navigator.pop(context);
                      }),
                      _buildSettingsChip('1.25x', currentSpeed == 1.25, () {
                        _videoPlayerController.setPlaybackSpeed(1.25);
                        setModalState(() {});
                        Navigator.pop(context);
                      }),
                      _buildSettingsChip('1.5x', currentSpeed == 1.5, () {
                        _videoPlayerController.setPlaybackSpeed(1.5);
                        setModalState(() {});
                        Navigator.pop(context);
                      }),
                      _buildSettingsChip('2.0x', currentSpeed == 2.0, () {
                        _videoPlayerController.setPlaybackSpeed(2.0);
                        setModalState(() {});
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),

                  // Quality switcher
                  const Text('Video Quality', style: TextStyle(color: AppTheme.silverAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSettingsChip('Auto', _selectedQuality == 'Auto', () {
                        setModalState(() => _selectedQuality = 'Auto');
                        _switchStream(widget.videoUrl);
                        Navigator.pop(context);
                      }),
                      ..._resolutions.entries.map((entry) {
                        return _buildSettingsChip(entry.key, _selectedQuality == entry.key, () {
                          setModalState(() => _selectedQuality = entry.key);
                          _switchStream(entry.value);
                          Navigator.pop(context);
                        });
                      }),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),

                  // Subtitles switcher
                  const Text('Subtitles (SRT / VTT)', style: TextStyle(color: AppTheme.silverAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSettingsChip('Off', _selectedSubtitle == null, () {
                        setModalState(() {
                          _selectedSubtitle = null;
                          _parsedSubtitles = [];
                          _currentSubtitleText = '';
                        });
                        Navigator.pop(context);
                      }),
                      ..._subtitleTracks.map((sub) {
                        final label = sub['language'] ?? 'Unknown';
                        final isSel = _selectedSubtitle != null && _selectedSubtitle!['url'] == sub['url'];
                        return _buildSettingsChip(label, isSel, () {
                          setModalState(() => _selectedSubtitle = sub);
                          _loadSubtitleTrack(sub['url']);
                          Navigator.pop(context);
                        });
                      }),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),

                  // Audio Track switcher
                  const Text('Audio Language Track', style: TextStyle(color: AppTheme.silverAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSettingsChip('Default', _selectedAudio == null, () {
                        setModalState(() => _selectedAudio = null);
                        _switchStream(widget.videoUrl);
                        Navigator.pop(context);
                      }),
                      ..._audioTracks.map((aud) {
                        final label = aud['language'] ?? 'Audio Track';
                        final isSel = _selectedAudio != null && _selectedAudio!['url'] == aud['url'];
                        return _buildSettingsChip(label, isSel, () {
                          setModalState(() => _selectedAudio = aud);
                          _switchStream(aud['url']);
                          Navigator.pop(context);
                        });
                      }),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppTheme.silverAccent, fontSize: 12)),
      selected: isSelected,
      selectedColor: AppTheme.royalPurple,
      backgroundColor: Colors.white10,
      onSelected: (_) => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _hasError
          ? _buildErrorWidget()
          : _chewieController == null
              ? const Center(child: CircularProgressIndicator(color: AppTheme.royalPurple))
              : Stack(
                  children: [
                    // Swipe handler + Player + Double-tap to seek
                    GestureDetector(
                      onVerticalDragUpdate: (details) => _handleVerticalSwipe(details, size.width),
                      onDoubleTapDown: (details) {
                        final x = details.localPosition.dx;
                        final isRightSide = x > (size.width / 2);
                        final currentPos = _videoPlayerController.value.position;
                        if (isRightSide) {
                          final newPos = currentPos + const Duration(seconds: 10);
                          _videoPlayerController.seekTo(newPos);
                          _showSeekIndicator('Skip +10s ⏩');
                        } else {
                          final newPos = currentPos - const Duration(seconds: 10);
                          _videoPlayerController.seekTo(newPos.clamp(Duration.zero, _videoPlayerController.value.duration));
                          _showSeekIndicator('Rewind -10s ⏪');
                        }
                      },
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: Chewie(controller: _chewieController!),
                        ),
                      ),
                    ),

                    // Subtitle Text Overlay
                    if (_currentSubtitleText.isNotEmpty)
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _currentSubtitleText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 2.0,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // HUD Overlay
                    if (_gestureIndicator != null)
                      Align(
                        alignment: Alignment.center,
                        child: GlassCard(
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          opacity: 0.2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _gestureIndicator!.contains('Volume')
                                    ? Icons.volume_up_outlined
                                    : Icons.brightness_medium_outlined,
                                color: AppTheme.softWhite,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _gestureIndicator!,
                                style: const TextStyle(
                                  color: AppTheme.softWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Back & Settings overlays
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppTheme.softWhite),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: AppTheme.softWhite),
                          onPressed: _showSettingsBottomSheet,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Failed to load video stream.',
            style: TextStyle(color: AppTheme.softWhite, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.royalPurple),
            child: const Text('Go Back'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
