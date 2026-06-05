const mongoose = require('mongoose');

const MovieSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please provide a title'],
    trim: true,
  },
  description: {
    type: String,
    required: [true, 'Please provide a description'],
  },
  thumbnailUrl: {
    type: String,
    required: [true, 'Please provide a thumbnail URL'],
  },
  bannerUrl: {
    type: String,
    required: [true, 'Please provide a banner URL'],
  },
  videoUrl: {
    type: String,
    required: [true, 'Please provide a streaming video URL'],
  },
  hlsUrl: {
    type: String,
    default: '',
  },
  resolutions: {
    type: Map,
    of: String,
    default: {},
  },
  trailerUrl: {
    type: String,
    default: '',
  },
  previewImages: [{
    type: String,
  }],
  subtitles: [{
    language: { type: String, required: true },
    url: { type: String, required: true },
    format: { type: String, enum: ['srt', 'vtt'], default: 'vtt' },
  }],
  audioTracks: [{
    language: { type: String, required: true },
    url: { type: String, required: true },
  }],
  type: {
    type: String,
    enum: ['movie', 'series'],
    default: 'movie',
  },
  rating: {
    type: Number,
    default: 0.0,
    min: 0,
    max: 10,
  },
  releaseYear: {
    type: Number,
    required: true,
  },
  duration: {
    type: String,
    required: true, // e.g. "2h 15m" or "8 Episodes"
  },
  genres: [{
    type: String,
    required: true,
  }],
  isPremium: {
    type: Boolean,
    default: false,
  },
  isFeatured: {
    type: Boolean,
    default: false,
  },
  cast: [String],
  crew: [String],
}, {
  timestamps: true,
});

module.exports = mongoose.model('Movie', MovieSchema);
