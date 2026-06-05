const Movie = require('../models/movie.model');
const { processVideoPipeline } = require('../services/ffmpeg.service');
const path = require('path');

exports.uploadMovie = async (req, res, next) => {
  try {
    const { 
      title, 
      description, 
      thumbnailUrl, 
      bannerUrl, 
      videoUrl, 
      rating, 
      releaseYear, 
      duration, 
      genres, 
      isPremium, 
      isFeatured,
      cast, 
      crew,
      subtitles,
      audioTracks
    } = req.body;

    if (!title || !description || !videoUrl || !releaseYear || !duration || !genres) {
      return res.status(400).json({ success: false, message: 'Missing required media details fields' });
    }

    const folderName = `movie_${Date.now()}`;
    let processedUrls = {
      hlsUrl: '',
      resolutions: {},
      trailerUrl: '',
      thumbnailUrl: thumbnailUrl || '',
      previewImages: [],
    };

    try {
      processedUrls = await processVideoPipeline(videoUrl, folderName);
    } catch (pipelineError) {
      console.error('⚠️ Pipeline processing failed, fallback to defaults:', pipelineError);
    }

    const movie = await Movie.create({
      title,
      description,
      thumbnailUrl: processedUrls.thumbnailUrl || thumbnailUrl || 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=500',
      bannerUrl: bannerUrl || 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1000',
      videoUrl,
      hlsUrl: processedUrls.hlsUrl || videoUrl,
      resolutions: processedUrls.resolutions || {},
      trailerUrl: processedUrls.trailerUrl || '',
      previewImages: processedUrls.previewImages || [],
      subtitles: subtitles || [],
      audioTracks: audioTracks || [],
      type: 'movie',
      rating: parseFloat(rating) || 0.0,
      releaseYear: parseInt(releaseYear),
      duration,
      genres: Array.isArray(genres) ? genres : genres.split(',').map(g => g.trim()),
      isPremium: isPremium === true || isPremium === 'true',
      isFeatured: isFeatured === true || isFeatured === 'true',
      cast: Array.isArray(cast) ? cast : (cast ? cast.split(',').map(c => c.trim()) : []),
      crew: Array.isArray(crew) ? crew : (crew ? crew.split(',').map(c => c.trim()) : []),
    });

    res.status(201).json({
      success: true,
      message: 'Movie registered and transcoding pipeline initialized successfully',
      data: movie,
    });
  } catch (error) {
    next(error);
  }
};

exports.uploadSeries = async (req, res, next) => {
  try {
    const { 
      title, 
      description, 
      thumbnailUrl, 
      bannerUrl, 
      videoUrl, 
      rating, 
      releaseYear, 
      duration, 
      genres, 
      isPremium, 
      isFeatured,
      cast, 
      crew,
      subtitles,
      audioTracks
    } = req.body;

    if (!title || !description || !videoUrl || !releaseYear || !duration || !genres) {
      return res.status(400).json({ success: false, message: 'Missing required media details fields' });
    }

    const folderName = `series_${Date.now()}`;
    let processedUrls = {
      hlsUrl: '',
      resolutions: {},
      trailerUrl: '',
      thumbnailUrl: thumbnailUrl || '',
      previewImages: [],
    };

    try {
      processedUrls = await processVideoPipeline(videoUrl, folderName);
    } catch (pipelineError) {
      console.error('⚠️ Series pipeline processing failed, fallback to defaults:', pipelineError);
    }

    const series = await Movie.create({
      title,
      description,
      thumbnailUrl: processedUrls.thumbnailUrl || thumbnailUrl || 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=500',
      bannerUrl: bannerUrl || 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1000',
      videoUrl,
      hlsUrl: processedUrls.hlsUrl || videoUrl,
      resolutions: processedUrls.resolutions || {},
      trailerUrl: processedUrls.trailerUrl || '',
      previewImages: processedUrls.previewImages || [],
      subtitles: subtitles || [],
      audioTracks: audioTracks || [],
      type: 'series',
      rating: parseFloat(rating) || 0.0,
      releaseYear: parseInt(releaseYear),
      duration,
      genres: Array.isArray(genres) ? genres : genres.split(',').map(g => g.trim()),
      isPremium: isPremium === true || isPremium === 'true',
      isFeatured: isFeatured === true || isFeatured === 'true',
      cast: Array.isArray(cast) ? cast : (cast ? cast.split(',').map(c => c.trim()) : []),
      crew: Array.isArray(crew) ? crew : (crew ? crew.split(',').map(c => c.trim()) : []),
    });

    res.status(201).json({
      success: true,
      message: 'TV Show series registered and transcoding pipeline initialized successfully',
      data: series,
    });
  } catch (error) {
    next(error);
  }
};
