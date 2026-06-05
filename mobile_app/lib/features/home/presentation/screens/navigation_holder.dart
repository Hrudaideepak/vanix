import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';

// Import Screens
import 'home_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../downloads/presentation/screens/downloads_screen.dart';
import '../../../watchlist/presentation/screens/watchlist_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../live_tv/presentation/screens/live_tv_screen.dart';

class NavigationHolder extends StatefulWidget {
  const NavigationHolder({super.key});

  @override
  State<NavigationHolder> createState() => _NavigationHolderState();
}

class _NavigationHolderState extends State<NavigationHolder> {
  int _currentIndex = 0;

  // Sidebar Items list
  final List<Map<String, dynamic>> _sidebarItems = [
    {'label': 'Home', 'icon': Icons.home_filled, 'inactiveIcon': Icons.home_outlined},
    {'label': 'Search', 'icon': Icons.search, 'inactiveIcon': Icons.search},
    {'label': 'TV Shows', 'icon': Icons.tv, 'inactiveIcon': Icons.tv_outlined},
    {'label': 'Movies', 'icon': Icons.movie_creation, 'inactiveIcon': Icons.movie_creation_outlined},
    {'label': 'Live TV', 'icon': Icons.live_tv, 'inactiveIcon': Icons.live_tv_outlined},
    {'label': 'My List', 'icon': Icons.playlist_add_check, 'inactiveIcon': Icons.playlist_add_check_outlined},
    {'label': 'Downloads', 'icon': Icons.download, 'inactiveIcon': Icons.download_outlined},
    {'label': 'Settings', 'icon': Icons.settings, 'inactiveIcon': Icons.settings_outlined},
  ];

  Widget _getSelectedScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(filterType: null);
      case 1:
        return const SearchScreen();
      case 2:
        return const HomeScreen(filterType: 'series');
      case 3:
        return const HomeScreen(filterType: 'movie');
      case 4:
        return const LiveTvScreen();
      case 5:
        return const WatchlistScreen();
      case 6:
        return const DownloadsScreen();
      case 7:
        return const ProfileScreen();
      default:
        return const HomeScreen(filterType: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;
    final isTablet = width >= 768 && width < 1200;

    if (isDesktop || isTablet) {
      return Scaffold(
        backgroundColor: AppTheme.deepBlack,
        body: Row(
          children: [
            // Left Sidebar
            _buildSidebar(isDesktop),
            
            // Vertical divider line
            Container(width: 1, color: Colors.white.withValues(alpha: 0.06)),
            
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Navigation Bar
                  _buildTopNav(),
                  
                  // Screen content
                  Expanded(
                    child: _getSelectedScreen(_currentIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile View with bottom navigation
    // Map mobile tab indexes back to global indices
    final List<int> mobileToGlobalMap = [0, 1, 4, 5, 7];
    int mobileIndex = mobileToGlobalMap.indexOf(_currentIndex);
    if (mobileIndex == -1) {
      mobileIndex = 0; // Fallback
    }

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _getSelectedScreen(_currentIndex),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: GlassCard(
          borderRadius: 24,
          opacity: 0.08,
          blur: 20,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMobileNavItem(0, mobileToGlobalMap[0], Icons.home_filled, Icons.home_outlined, 'Home'),
              _buildMobileNavItem(1, mobileToGlobalMap[1], Icons.search, Icons.search, 'Search'),
              _buildMobileNavItem(2, mobileToGlobalMap[2], Icons.live_tv, Icons.live_tv_outlined, 'Live TV'),
              _buildMobileNavItem(3, mobileToGlobalMap[3], Icons.bookmark, Icons.bookmark_outline, 'Watchlist'),
              _buildMobileNavItem(4, mobileToGlobalMap[4], Icons.person, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isDesktop) {
    return Container(
      width: isDesktop ? 260 : 80,
      color: AppTheme.cardGrey.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Logo Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 0, vertical: 12),
            child: isDesktop
                ? Text(
                    'VANIX',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      foreground: Paint()
                        ..shader = AppTheme.premiumGradient.createShader(
                          const Rect.fromLTWH(0.0, 0.0, 150.0, 30.0),
                        ),
                    ),
                  )
                : const Icon(
                    Icons.movie_creation,
                    size: 32,
                    color: AppTheme.royalPurple,
                  ),
          ),
          const SizedBox(height: 32),

          // Sidebar Navigation Items
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                final isSelected = _currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppTheme.royalPurple.withValues(alpha: 0.12) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppTheme.royalPurple.withValues(alpha: 0.2) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item['icon'] : item['inactiveIcon'],
                          color: isSelected ? AppTheme.royalPurple : AppTheme.silverAccent.withValues(alpha: 0.6),
                          size: 22,
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 14),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppTheme.softWhite : AppTheme.silverAccent.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Premium Upgrade Card (Desktop only)
          if (isDesktop)
            GlassCard(
              borderRadius: 16,
              opacity: 0.06,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium, color: AppTheme.electricBlue, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'VANIX Premium',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upgrade plan to unlock ultra 4K HDR streaming.',
                    style: TextStyle(fontSize: 10, color: AppTheme.silverAccent.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 7; // Go to settings/profile plan screen
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppTheme.premiumGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Upgrade Plan',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Input Mock
          GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = 1; // Go to search screen
              });
            },
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppTheme.silverAccent.withValues(alpha: 0.5), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Search titles, genres, creators...',
                    style: TextStyle(color: AppTheme.silverAccent.withValues(alpha: 0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // User Panel
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppTheme.softWhite, size: 22),
                onPressed: () {},
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 7; // Go to settings/profile
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.royalPurple, width: 1.5),
                  ),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://api.dicebear.com/7.x/bottts/png?seed=Primary'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavItem(int navIndex, int globalIndex, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == globalIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = globalIndex;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? AppTheme.premiumGradient : null,
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? Colors.white : AppTheme.silverAccent.withValues(alpha: 0.6),
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.softWhite : AppTheme.silverAccent.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
