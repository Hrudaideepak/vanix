import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/vanix_image.dart';
import '../../providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<String> _genres = ['All', 'Sci-Fi', 'Cyberpunk', 'Action', 'Thriller', 'Adventure', 'Fantasy'];
  final List<String> _types = ['All', 'Movies', 'Series'];

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, SearchProvider provider) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      provider.search(query);
    });
  }

  void _triggerVoiceSearch(SearchProvider provider) {
    // Premium Voice Search Dialog simulation
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardGrey,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Listening for search...',
                style: TextStyle(color: AppTheme.silverAccent.withValues(alpha: 0.7), fontSize: 16),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.royalPurple.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.mic, color: AppTheme.royalPurple, size: 48)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.25, duration: 800.ms, curve: Curves.easeInOut),
              ),
              const SizedBox(height: 30),
              const Text(
                '"Nebula Genesis"',
                style: TextStyle(color: AppTheme.softWhite, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.royalPurple),
                child: const Text('Search Voice Input'),
                onPressed: () {
                  _searchController.text = 'Nebula';
                  provider.search('Nebula');
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

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
              // Search Input Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.softWhite),
                        onChanged: (val) => _onSearchChanged(val, searchProvider),
                        decoration: InputDecoration(
                          hintText: 'Search movies, TV shows, and web series...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.silverAccent),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppTheme.silverAccent),
                                  onPressed: () {
                                    _searchController.clear();
                                    searchProvider.search('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _triggerVoiceSearch(searchProvider),
                      child: const GlassCard(
                        borderRadius: 12,
                        opacity: 0.08,
                        padding: EdgeInsets.all(15),
                        child: Icon(Icons.mic, color: AppTheme.royalPurple, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Shelf: Genres & Types
              _buildFilterSection(searchProvider),

              const SizedBox(height: 12),

              // Search Body Contents
              Expanded(
                child: _searchController.text.trim().isEmpty
                    ? _buildSearchHistorySection(searchProvider)
                    : _buildSearchResultsGrid(searchProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(SearchProvider provider) {
    return Column(
      children: [
        // Types Row
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _types.length,
            itemBuilder: (context, index) {
              final type = _types[index];
              final isSelected = provider.selectedType == type;
              return GestureDetector(
                onTap: () {
                  provider.updateFilters(type: type);
                  provider.search(_searchController.text);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: isSelected ? AppTheme.premiumGradient : null,
                    color: isSelected ? null : AppTheme.softWhite.withValues(alpha: 0.04),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.softWhite.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.softWhite : AppTheme.silverAccent.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Genres Row
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _genres.length,
            itemBuilder: (context, index) {
              final genre = _genres[index];
              final isSelected = provider.selectedGenre == genre;
              return GestureDetector(
                onTap: () {
                  provider.updateFilters(genre: genre);
                  provider.search(_searchController.text);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppTheme.royalPurple : AppTheme.softWhite.withValues(alpha: 0.08),
                    ),
                    color: isSelected ? AppTheme.royalPurple.withValues(alpha: 0.15) : AppTheme.softWhite.withValues(alpha: 0.02),
                  ),
                  child: Text(
                    genre,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.royalPurple : AppTheme.silverAccent.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHistorySection(SearchProvider provider) {
    if (provider.recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppTheme.silverAccent.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'Explore VANIX Universe',
              style: TextStyle(color: AppTheme.silverAccent.withValues(alpha: 0.5), fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.softWhite),
              ),
              GestureDetector(
                onTap: () => provider.clearRecentSearches(),
                child: Text(
                  'Clear All',
                  style: TextStyle(fontSize: 13, color: AppTheme.royalPurple.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: provider.recentSearches.map((keyword) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = keyword;
                  provider.search(keyword);
                },
                child: GlassCard(
                  borderRadius: 8,
                  opacity: 0.05,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, color: AppTheme.silverAccent, size: 14),
                      const SizedBox(width: 8),
                      Text(keyword, style: const TextStyle(color: AppTheme.silverAccent, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsGrid(SearchProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.royalPurple));
    }

    if (provider.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 64, color: AppTheme.silverAccent.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text(
              'No matches found in this sector.',
              style: TextStyle(color: AppTheme.silverAccent, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final movie = provider.searchResults[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/movie-details',
            arguments: {'id': movie.id, 'type': movie.type},
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                VanixImage(imageUrl: movie.thumbnailUrl),
                if (movie.isPremium)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium, size: 10, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
