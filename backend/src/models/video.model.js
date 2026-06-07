const mongoose = require('mongoose');

const videoSchema = new mongoose.Schema({
  title: { 
    type: String, 
    required: [true, 'Please provide a title'],
    trim: true,
  },
  description: { 
    type: String,
    default: '',
  },
  genre: {
    type: String,
    default: 'Uncategorized',
  },
  posterUrl: {
    type: String,
    default: '',
  },
  originalUrl: {
    type: String,
    default: '',
  },
  hlsPlaylistUrl: {
    type: String,
    default: '',
  },
  thumbnailUrls: {
    type: [String],
    default: [],
  },
  duration: {
    type: Number,
    default: 0,
  },
  resolution: {
    type: String,
    default: '',
  },
  bitrate: {
    type: String,
    default: '',
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed'],
    default: 'pending',
  },
  transcodingError: {
    type: String,
    default: '',
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Video', videoSchema);
