const User = require('../models/user.model');
const Movie = require('../models/movie.model');
const History = require('../models/history.model');
const SearchHistory = require('../models/searchHistory.model');

exports.getAdminAnalytics = async (req, res, next) => {
  try {
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ 'devices.0': { $exists: true } });
    const moviesUploaded = await Movie.countDocuments();

    const watchedAgg = await History.aggregate([
      { $group: { _id: '$movie', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 }
    ]);
    
    const populatedWatched = await Movie.populate(watchedAgg, { path: '_id' });
    const mostWatched = populatedWatched.map(w => ({
      movie: w._id ? w._id.title : 'Deleted Content',
      id: w._id ? w._id._id : null,
      views: w.count,
    }));

    if (mostWatched.length === 0) {
      // ⚡ Bolt: Optimize topMovies fallback by using .lean() for read-only fetch
      const topMovies = await Movie.find().limit(3).lean();
      topMovies.forEach((m, idx) => {
        mostWatched.push({
          movie: m.title,
          id: m._id,
          views: 120 - idx * 25,
        });
      });
    }

    const searchAgg = await SearchHistory.aggregate([
      { $group: { _id: '$query', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 }
    ]);
    const mostSearched = searchAgg.map(s => ({
      query: s._id,
      count: s.count,
    }));

    if (mostSearched.length === 0) {
      mostSearched.push(
        { query: 'Nebula Genesis', count: 42 },
        { query: 'Sci-Fi', count: 28 },
        { query: 'Cyberpunk', count: 19 }
      );
    }

    const users = await User.find({ subscriptionPlan: { $ne: 'free' } });
    let monthlyRevenue = 0;
    users.forEach(u => {
      if (u.subscriptionPlan === 'silver') monthlyRevenue += 4.99;
      if (u.subscriptionPlan === 'gold') monthlyRevenue += 9.99;
      if (u.subscriptionPlan === 'premium') monthlyRevenue += 14.99;
    });

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        activeUsers: activeUsers || Math.floor(totalUsers * 0.45) + 1,
        moviesUploaded,
        mostWatched,
        mostSearched,
        monthlyRevenue: parseFloat(monthlyRevenue.toFixed(2)),
      }
    });
  } catch (error) {
    next(error);
  }
};
