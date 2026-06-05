const Movie = require('../models/movie.model');
const History = require('../models/history.model');

/**
 * Generate recommendations for a user based on their watch history.
 * @param {string} userId - Mongo ID of the user.
 * @param {number} limit - Maximum number of items to return.
 */
exports.getRecommendations = async (userId, limit = 6) => {
  try {
    // 1. Fetch user watch history
    const history = await History.find({ user: userId })
      .populate('movie')
      .sort({ updatedAt: -1 })
      .limit(10);

    if (!history || history.length === 0) {
      // Fallback: No history, return top-rated movies
      return await Movie.find().sort({ rating: -1 }).limit(limit);
    }

    // 2. Extract and count favorite genres
    const genreCounts = {};
    const watchedMovieIds = [];

    history.forEach(item => {
      if (item.movie) {
        watchedMovieIds.push(item.movie._id.toString());
        item.movie.genres.forEach(g => {
          genreCounts[g] = (genreCounts[g] || 0) + 1;
        });
      }
    });

    // Sort genres by frequency
    const favoriteGenres = Object.keys(genreCounts).sort((a, b) => genreCounts[b] - genreCounts[a]);

    // 3. Query movies that match favorite genres, excluding already fully watched ones
    let recommendations = await Movie.find({
      genres: { $in: favoriteGenres.slice(0, 2) }, // Match top 2 favorite genres
      _id: { $nin: watchedMovieIds },              // Exclude already watched
    })
      .sort({ rating: -1 })
      .limit(limit);

    // 4. Fallback if not enough recommendations
    if (recommendations.length < limit) {
      const remainingLimit = limit - recommendations.length;
      const additional = await Movie.find({
        _id: { $nin: [...watchedMovieIds, ...recommendations.map(r => r._id.toString())] }
      })
        .sort({ rating: -1 })
        .limit(remainingLimit);
        
      recommendations = [...recommendations, ...additional];
    }

    return recommendations;
  } catch (error) {
    console.error('Error generating recommendations:', error);
    // Fallback: return any content
    return await Movie.find().limit(limit);
  }
};
