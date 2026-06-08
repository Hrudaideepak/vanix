const Movie = require('../models/movie.model');
const { processVideoPipeline } = require('../services/ffmpeg.service');
const path = require('path');

const handleUpload = async (req, res, next, type) => {
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

    const folderName = `${type}_${Date.now()}`;
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
      console.error(`⚠️ ${type === 'series' ? 'Series p' : 'P'}ipeline processing failed, fallback to defaults:`, pipelineError);
    }

    const media = await Movie.create({
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
      type: type,
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
      message: `${type === 'series' ? 'TV Show series' : 'Movie'} registered and transcoding pipeline initialized successfully`,
      data: media,
    });
  } catch (error) {
    next(error);
  }
};

exports.uploadMovie = async (req, res, next) => {
  return handleUpload(req, res, next, 'movie');
};

exports.uploadSeries = async (req, res, next) => {
  return handleUpload(req, res, next, 'series');
};
