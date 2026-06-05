const History = require('../models/history.model');
const Movie = require('../models/movie.model');

exports.getHistory = async (req, res, next) => {
  try {
    if (!req.profile) {
      return res.status(400).json({ success: false, message: 'Profile context is required. Attach x-profile-id header.' });
    }

    const query = { profile: req.profile._id };
    
    if (req.query.movieId) {
      query.movie = req.query.movieId;
      const singleItem = await History.findOne(query).sort({ lastWatchedDate: -1 });
      return res.status(200).json({ success: true, data: singleItem });
    }

    const list = await History.find(query)
      .populate('movie')
      .sort({ lastWatchedDate: -1 });

    res.status(200).json({
      success: true,
      count: list.length,
      data: list,
    });
  } catch (error) {
    next(error);
  }
};

exports.saveHistory = async (req, res, next) => {
  try {
    const { movieId, episodeId, progress, watchedTime } = req.body;

    if (!movieId) {
      return res.status(400).json({ success: false, message: 'Movie ID is required' });
    }

    if (!req.profile) {
      return res.status(400).json({ success: false, message: 'Profile context is required. Attach x-profile-id header.' });
    }

    let historyItem = await History.findOne({ profile: req.profile._id, movie: movieId, episodeId });

    const watchPercentage = Math.round(progress * 100);
    const lastPosition = watchedTime;
    const lastWatchedDate = new Date();

    if (historyItem) {
      historyItem.progress = progress;
      historyItem.watchedTime = watchedTime;
      historyItem.watchPercentage = watchPercentage;
      historyItem.lastPosition = lastPosition;
      historyItem.lastWatchedDate = lastWatchedDate;
      await historyItem.save();
    } else {
      historyItem = await History.create({
        user: req.user.id,
        profile: req.profile._id,
        movie: movieId,
        episodeId,
        progress,
        watchedTime,
        watchPercentage,
        lastPosition,
        lastWatchedDate,
      });
    }

    res.status(200).json({
      success: true,
      data: historyItem,
    });
  } catch (error) {
    next(error);
  }
};
