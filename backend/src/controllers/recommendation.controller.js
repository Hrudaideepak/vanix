const Movie = require('../models/movie.model');
const History = require('../models/history.model');

const getSafetyQuery = (profile, baseQuery = {}) => {
  if (profile && profile.isKids) {
    return {
      ...baseQuery,
      genres: { $in: ['Kids', 'Animation', 'Family', 'Sci-Fi', 'Fantasy'] }
    };
  }
  return baseQuery;
};

const getBecauseYouWatched = async (profile, history, limit) => {
  if (history.length > 0 && history[0].movie) {
    const lastMovie = history[0].movie;
    const genresToMatch = lastMovie.genres.slice(0, 2);

    const matchQuery = getSafetyQuery(profile, {
      genres: { $in: genresToMatch },
      _id: { $ne: lastMovie._id },
    });

    const movies = await Movie.find(matchQuery).limit(limit);
    return {
      title: `Because you watched ${lastMovie.title}`,
      data: movies,
    };
  } else {
    const matchQuery = getSafetyQuery(profile, { genres: 'Sci-Fi' });
    const movies = await Movie.find(matchQuery).sort({ rating: -1 }).limit(limit);
    return {
      title: 'Popular in Sci-Fi',
      data: movies,
    };
  }
};

const getRecommendedForYou = async (profile, history, limit) => {
  let recommendedQuery = getSafetyQuery(profile, {});
  const watchedIds = history.map(h => h.movie?._id).filter(Boolean);

  if (history.length > 0) {
    const genreCounts = {};
    history.forEach(h => {
      if (h.movie) {
        h.movie.genres.forEach(g => {
          genreCounts[g] = (genreCounts[g] || 0) + 1;
        });
      }
    });
    const topGenres = Object.keys(genreCounts).sort((a, b) => genreCounts[b] - genreCounts[a]);
    if (topGenres.length > 0) {
      recommendedQuery.genres = { $in: topGenres.slice(0, 2) };
    }
  }

  recommendedQuery._id = { $nin: watchedIds };

  let recommendedForYou = await Movie.find(recommendedQuery).sort({ rating: -1 }).limit(limit);
  if (recommendedForYou.length < limit) {
    const fillLimit = limit - recommendedForYou.length;
    const fillQuery = getSafetyQuery(profile, {
      _id: { $nin: [...watchedIds, ...recommendedForYou.map(r => r._id)] }
    });
    const fillMovies = await Movie.find(fillQuery).sort({ rating: -1 }).limit(fillLimit);
    recommendedForYou = [...recommendedForYou, ...fillMovies];
  }

  return recommendedForYou;
};

const getTrendingNearYou = async (profile, limit) => {
  const trendingQuery = getSafetyQuery(profile, {});
  return await Movie.find(trendingQuery).sort({ rating: -1, releaseYear: -1 }).limit(limit);
};

const getFeaturedMovies = async (profile) => {
  const featuredQuery = getSafetyQuery(profile, { isFeatured: true });
  let featured = await Movie.find(featuredQuery).limit(5);
  if (featured.length === 0) {
    featured = await Movie.find(getSafetyQuery(profile, {})).sort({ rating: -1 }).limit(5);
  }
  return featured;
};

exports.getHomeRecommendations = async (req, res, next) => {
  try {
    if (!req.profile) {
      return res.status(400).json({ success: false, message: 'Profile header x-profile-id is required' });
    }

    const limit = 6;
    
    const history = await History.find({ profile: req.profile._id })
      .populate('movie')
      .sort({ lastWatchedDate: -1 })
      .limit(5);

    const becauseYouWatched = await getBecauseYouWatched(req.profile, history, limit);
    const recommendedForYou = await getRecommendedForYou(req.profile, history, limit);
    const trendingNearYou = await getTrendingNearYou(req.profile, limit);
    const featured = await getFeaturedMovies(req.profile);

    res.status(200).json({
      success: true,
      data: {
        featured,
        sections: [
          {
            key: 'because_you_watched',
            title: becauseYouWatched.title,
            data: becauseYouWatched.data,
          },
          {
            key: 'recommended_for_you',
            title: 'Recommended For You',
            data: recommendedForYou,
          },
          {
            key: 'trending_near_you',
            title: 'Trending Near You',
            data: trendingNearYou,
          },
        ]
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.getSimilarContent = async (req, res, next) => {
  try {
    const movie = await Movie.findById(req.params.id);
    if (!movie) {
      return res.status(404).json({ success: false, message: 'Content not found' });
    }

    const safetyQuery = getSafetyQuery(req.profile, {
      genres: { $in: movie.genres },
      _id: { $ne: movie._id },
    });

    const similar = await Movie.find(safetyQuery).sort({ rating: -1 }).limit(6);

    res.status(200).json({
      success: true,
      count: similar.length,
      data: similar,
    });
  } catch (error) {
    next(error);
  }
};
