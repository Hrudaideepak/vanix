const Movie = require('../models/movie.model');
const { getRecommendations } = require('../services/recommendation.service');
const { generateSignedStreamingUrl } = require('../utils/security');
const { escapeRegExp } = require('../utils/regex');

// @desc    Get all movies/content
// @route   GET /api/movies
// @access  Public
exports.getMovies = async (req, res, next) => {
  try {
    const { genre, type, recommendedFor } = req.query;
    let query = {};

    if (genre && genre !== 'All') {
      query.genres = genre;
    }
    if (type && type !== 'All') {
      query.type = type.toLowerCase();
    }

    if (req.profile && req.profile.isKids) {
      query.genres = { $in: ['Kids', 'Animation', 'Family', 'Sci-Fi', 'Fantasy'] };
    }

    let movies;
    if (recommendedFor && req.user) {
      movies = await getRecommendations(req.user.id, 6);
    } else {
      movies = await Movie.find(query).sort({ createdAt: -1 }).lean();
    }

    res.status(200).json({
      success: true,
      count: movies.length,
      data: movies,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single movie/content by ID
// @route   GET /api/movie/:id
// @access  Public
exports.getMovieById = async (req, res, next) => {
  try {
    const movie = await Movie.findById(req.params.id).lean();

    if (!movie) {
      return res.status(404).json({ success: false, message: 'Content not found' });
    }

    // Check subscription plan locks for premium videos
    if (movie.isPremium) {
      if (!req.user) {
        return res.status(401).json({ success: false, message: 'Authorization required for premium content' });
      }
      
      const hasSubscription = req.user.subscriptionPlan !== 'free' && 
                             (req.user.subscriptionExpires === null || new Date(req.user.subscriptionExpires) > new Date());
                             
      if (!hasSubscription) {
        return res.status(403).json({
          success: false,
          isLocked: true,
          message: `This content requires a Silver, Gold, or Premium subscription plan. Current status: ${req.user.subscriptionPlan}`,
        });
      }
    }

    // Sign video url
    movie.videoUrl = generateSignedStreamingUrl(movie.videoUrl);

    res.status(200).json({
      success: true,
      data: movie,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all unique categories/genres
// @route   GET /api/categories
// @access  Public
exports.getCategories = async (req, res, next) => {
  try {
    const genres = await Movie.distinct('genres');
    res.status(200).json({
      success: true,
      data: genres,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Real-time text query search
// @route   GET /api/search
// @access  Public
exports.searchContent = async (req, res, next) => {
  try {
    const { q, genre, type } = req.query;
    let query = {};

    if (q) {
      const safeQuery = escapeRegExp(q);
      query.$or = [
        { title: { $regex: safeQuery, $options: 'i' } },
        { description: { $regex: safeQuery, $options: 'i' } },
      ];
    }
    
    if (genre && genre !== 'All') {
      query.genres = genre;
    }
    
    if (type && type !== 'All') {
      query.type = type.toLowerCase();
    }

    const results = await Movie.find(query).limit(20).lean();

    res.status(200).json({
      success: true,
      count: results.length,
      data: results,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete movie/content by ID
// @route   DELETE /api/movie/:id
// @access  Private/Admin
exports.deleteMovie = async (req, res, next) => {
  try {
    const movie = await Movie.findById(req.params.id);
    if (!movie) {
      return res.status(404).json({ success: false, message: 'Content not found' });
    }
    await Movie.findByIdAndDelete(req.params.id);
    res.status(200).json({
      success: true,
      message: 'Content deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
