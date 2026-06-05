const Watchlist = require('../models/watchlist.model');
const Movie = require('../models/movie.model');

exports.getWatchlist = async (req, res, next) => {
  try {
    if (!req.profile) {
      return res.status(400).json({ success: false, message: 'Profile context is required. Attach x-profile-id header.' });
    }

    const list = await Watchlist.find({ profile: req.profile._id }).populate('movie');
    const movies = list.map(item => item.movie).filter(Boolean);

    res.status(200).json({
      success: true,
      count: movies.length,
      data: movies,
    });
  } catch (error) {
    next(error);
  }
};

exports.addToWatchlist = async (req, res, next) => {
  try {
    const { movieId } = req.body;

    if (!movieId) {
      return res.status(400).json({ success: false, message: 'Movie ID is required' });
    }

    if (!req.profile) {
      return res.status(400).json({ success: false, message: 'Profile context is required. Attach x-profile-id header.' });
    }

    const movie = await Movie.findById(movieId);
    if (!movie) {
      return res.status(404).json({ success: false, message: 'Movie not found' });
    }

    const exists = await Watchlist.findOne({ profile: req.profile._id, movie: movieId });
    if (exists) {
      return res.status(400).json({ success: false, message: 'Movie already in watchlist' });
    }

    const watchlistItem = await Watchlist.create({
      user: req.user.id,
      profile: req.profile._id,
      movie: movieId,
    });

    res.status(201).json({
      success: true,
      data: watchlistItem,
    });
  } catch (error) {
    next(error);
  }
};

exports.removeFromWatchlist = async (req, res, next) => {
  try {
    if (!req.profile) {
      return res.status(400).json({ success: false, message: 'Profile context is required. Attach x-profile-id header.' });
    }

    const item = await Watchlist.findOneAndDelete({
      profile: req.profile._id,
      movie: req.params.id,
    });

    if (!item) {
      return res.status(404).json({ success: false, message: 'Watchlist item not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Successfully removed item from watchlist',
    });
  } catch (error) {
    next(error);
  }
};
