class ContentModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String bannerUrl;
  final String videoUrl;
  final String trailerUrl;
  final String type; // 'movie' or 'series'
  final double rating;
  final int releaseYear;
  final String duration;
  final List<String> genres;
  final bool isPremium;
  final double progress; // 0.0 to 1.0 representing watch progress percentage
  final List<String> cast;
  final List<String> crew;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.bannerUrl,
    required this.videoUrl,
    this.trailerUrl = '',
    required this.type,
    required this.rating,
    required this.releaseYear,
    required this.duration,
    required this.genres,
    required this.isPremium,
    this.progress = 0.0,
    this.cast = const [],
    this.crew = const [],
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      bannerUrl: json['bannerUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      trailerUrl: json['trailerUrl'] ?? '',
      type: json['type'] ?? 'movie',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      releaseYear: json['releaseYear'] as int? ?? 2024,
      duration: json['duration'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      isPremium: json['isPremium'] ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      cast: List<String>.from(json['cast'] ?? []),
      crew: List<String>.from(json['crew'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'bannerUrl': bannerUrl,
      'videoUrl': videoUrl,
      'trailerUrl': trailerUrl,
      'type': type,
      'rating': rating,
      'releaseYear': releaseYear,
      'duration': duration,
      'genres': genres,
      'isPremium': isPremium,
      'progress': progress,
      'cast': cast,
      'crew': crew,
    };
  }
}
