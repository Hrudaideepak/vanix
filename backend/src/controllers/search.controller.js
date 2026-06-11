const Movie = require('../models/movie.model');
const SearchHistory = require('../models/searchHistory.model');

const getLevenshteinDistance = (a, b) => {
  const tmp = [];
  let i, j, alen = a.length, blen = b.length, cost;
  if (alen === 0) return blen;
  if (blen === 0) return alen;
  for (i = 0; i <= alen; i++) tmp[i] = [i];
  for (j = 0; j <= blen; j++) tmp[0][j] = j;
  for (i = 1; i <= alen; i++) {
    for (j = 1; j <= blen; j++) {
      cost = (a[i - 1].toLowerCase() === b[j - 1].toLowerCase()) ? 0 : 1;
      tmp[i][j] = Math.min(tmp[i - 1][j] + 1, tmp[i][j - 1] + 1, tmp[i - 1][j - 1] + cost);
    }
  }
  return tmp[alen][blen];
};

exports.smartSearch = async (req, res, next) => {
  try {
    const { q, genre, type } = req.query;
    
    if (!q) {
      return res.status(200).json({ success: true, count: 0, data: [] });
    }

    let filter = {};
    if (genre && genre !== 'All') filter.genres = genre;
    if (type && type !== 'All') filter.type = type.toLowerCase();

    const escapeRegExp = (string) => string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regexQuery = new RegExp(escapeRegExp(q.trim()), 'i');
    filter.$or = [
      { title: regexQuery },
      { description: regexQuery },
      { cast: regexQuery },
    ];

    if (req.profile && req.profile.isKids) {
      filter.genres = { $in: ['Kids', 'Animation', 'Family', 'Sci-Fi', 'Fantasy'] };
    }

    let results = await Movie.find(filter).limit(20).lean();

    let typoCorrected = false;
    let suggestedQuery = null;
    if (results.length === 0) {
      // ⚡ Bolt: Optimize typo correction by only loading _id and title, and using lean()
      const allMovies = await Movie.find(req.profile && req.profile.isKids ? { genres: { $in: ['Kids', 'Animation', 'Family', 'Sci-Fi', 'Fantasy'] } } : {}).select('_id title').lean();
      const matches = [];
      const queryWords = q.trim().toLowerCase().split(/\s+/);
      
      allMovies.forEach(movie => {
        const titleWords = movie.title.toLowerCase().split(/\s+/);
        let minDistance = 999;
        queryWords.forEach(qw => {
          titleWords.forEach(tw => {
            const dist = getLevenshteinDistance(qw, tw);
            if (dist < minDistance) minDistance = dist;
          });
        });

        if (minDistance <= 2) {
          matches.push({ id: movie._id, distance: minDistance, title: movie.title });
        }
      });

      if (matches.length > 0) {
        matches.sort((a, b) => a.distance - b.distance);
        const topMatches = matches.slice(0, 5);

        // Fetch the full documents for the matched movies
        const matchedIds = topMatches.map(m => m.id);
        const matchedMovies = await Movie.find({ _id: { $in: matchedIds } }).lean();

        // Maintain the sorted order based on distance
        results = topMatches.map(m => matchedMovies.find(movie => movie._id.toString() === m.id.toString())).filter(Boolean);

        typoCorrected = true;
        suggestedQuery = topMatches[0].title;
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

let cachedTrending = null;
let lastTrendingCacheTime = null;
const TRENDING_CACHE_TTL = 5 * 60 * 1000; // 5 minutes

exports.getTrendingSearches = async (req, res, next) => {
  try {
    const now = Date.now();
    // ⚡ Bolt: Return cached trending searches if valid (O(1) memory lookup instead of O(N) database aggregation)
    if (cachedTrending && lastTrendingCacheTime && (now - lastTrendingCacheTime < TRENDING_CACHE_TTL)) {
      return res.status(200).json({
        success: true,
        data: cachedTrending,
      });
    }

    const aggregates = await SearchHistory.aggregate([
      { $group: { _id: '$query', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 }
    ]);

    let trending = aggregates.map(a => a._id);
    
    if (trending.length < 3) {
      trending = ['Nebula Genesis', 'Cyberpunk', 'Space Odyssey', 'Ragnarok Rising', 'Chronicles of Chronos'];
    }

    cachedTrending = trending;
    lastTrendingCacheTime = now;

    res.status(200).json({
      success: true,
      data: trending,
    });
  } catch (error) {
    next(error);
  }
};
