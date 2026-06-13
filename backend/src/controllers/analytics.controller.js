const User = require('../models/user.model');
const Movie = require('../models/movie.model');
const History = require('../models/history.model');
const SearchHistory = require('../models/searchHistory.model');

exports.getAdminAnalytics = async (req, res, next) => {
  try {
    // ⚡ Bolt: Batch independent Mongoose database queries using Promise.all() to prevent cumulative I/O blocking
    const [
      totalUsers,
      activeUsers,
      moviesUploaded,
      watchedAgg,
      searchAgg,
      revenueAgg
    ] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ 'devices.0': { $exists: true } }),
      Movie.countDocuments(),
      History.aggregate([
        { $group: { _id: '$movie', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 5 }
      ]),
      SearchHistory.aggregate([
        { $group: { _id: '$query', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 5 }
      ]),
      // ⚡ Bolt: Optimize monthly revenue calculation using MongoDB aggregation instead of fetching all users into memory
      User.aggregate([
        { $match: { subscriptionPlan: { $ne: 'free' } } },
        { $group: { _id: '$subscriptionPlan', count: { $sum: 1 } } }
      ])
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

    let monthlyRevenue = 0;
    revenueAgg.forEach(plan => {
      if (plan._id === 'silver') monthlyRevenue += plan.count * 4.99;
      if (plan._id === 'gold') monthlyRevenue += plan.count * 9.99;
      if (plan._id === 'premium') monthlyRevenue += plan.count * 14.99;
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
