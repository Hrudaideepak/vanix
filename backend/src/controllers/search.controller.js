const Movie = require('../models/movie.model');
const SearchHistory = require('../models/searchHistory.model');

const levenshtein = require('fast-levenshtein');

exports.smartSearch = async (req, res, next) => {
  try {
    const { q, genre, type } = req.query;
    
    if (!q) {
      return res.status(200).json({ success: true, count: 0, data: [] });
    }

    let filter = {};
    if (genre && genre !== 'All') filter.genres = genre;
    if (type && type !== 'All') filter.type = type.toLowerCase();

    const regexQuery = new RegExp(q.trim(), 'i');
    filter.$or = [
      { title: regexQuery },
      { description: regexQuery },
      { cast: regexQuery },
    ];

    if (req.profile && req.profile.isKids) {
      filter.genres = { $in: ['Kids', 'Animation', 'Family', 'Sci-Fi', 'Fantasy'] };
    }

    let results = await Movie.find(filter).limit(20);

    let typoCorrected = false;
    let suggestedQuery = null;
    if (results.length === 0) {
      const allMovies = await Movie.find(req.profile && req.profile.isKids ? { genres: { $in: ['Kids', 'Animation', 'Family', 'Sci-Fi', 'Fantasy'] } } : {});
      const matches = [];
      const queryWords = q.trim().toLowerCase().split(/\s+/);
      
      allMovies.forEach(movie => {
        const titleWords = movie.title.toLowerCase().split(/\s+/);
        let minDistance = 999;
        queryWords.forEach(qw => {
          titleWords.forEach(tw => {
            const dist = levenshtein.get(qw.toLowerCase(), tw.toLowerCase());
            if (dist < minDistance) minDistance = dist;
          });
        });

        if (minDistance <= 2) {
          matches.push({ movie, distance: minDistance });
        }
      });

      if (matches.length > 0) {
        matches.sort((a, b) => a.distance - b.distance);
        results = matches.map(m => m.movie).slice(0, 5);
        typoCorrected = true;
        suggestedQuery = results[0].title;
      }
    }

    if (req.profile) {
      const queryText = q.trim().toLowerCase();
      await SearchHistory.deleteMany({ profile: req.profile._id, query: queryText });
      await SearchHistory.create({
        profile: req.profile._id,
        query: q.trim(),
      });

      const histories = await SearchHistory.find({ profile: req.profile._id }).sort({ searchedAt: -1 });
      if (histories.length > 10) {
        const toDelete = histories.slice(10);
        await SearchHistory.deleteMany({ _id: { $in: toDelete.map(h => h._id) } });
      }
    }

    res.status(200).json({
      success: true,
      count: results.length,
      typoCorrected,
      suggestedQuery,
      data: results,
    });
  } catch (error) {
    next(error);
  }
};

exports.getRecentSearches = async (req, res, next) => {
  try {
    if (!req.profile) {
      return res.status(400).json({ success: false, message: 'Profile header x-profile-id is required' });
    }

    const recents = await SearchHistory.find({ profile: req.profile._id })
      .sort({ searchedAt: -1 })
      .limit(10);

    res.status(200).json({
      success: true,
      data: recents.map(r => r.query),
    });
  } catch (error) {
    next(error);
  }
};

exports.clearRecentSearches = async (req, res, next) => {
  try {
    if (!req.profile) {
      return res.status(400).json({ success: false, message: 'Profile header x-profile-id is required' });
    }

    await SearchHistory.deleteMany({ profile: req.profile._id });

    res.status(200).json({
      success: true,
      message: 'Recent search history cleared',
    });
  } catch (error) {
    next(error);
  }
};

exports.getTrendingSearches = async (req, res, next) => {
  try {
    const aggregates = await SearchHistory.aggregate([
      { $group: { _id: '$query', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 }
    ]);

    let trending = aggregates.map(a => a._id);
    
    if (trending.length < 3) {
      trending = ['Nebula Genesis', 'Cyberpunk', 'Space Odyssey', 'Ragnarok Rising', 'Chronicles of Chronos'];
    }

    res.status(200).json({
      success: true,
      data: trending,
    });
  } catch (error) {
    next(error);
  }
};
