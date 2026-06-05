const mongoose = require('mongoose');

const HistorySchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  profile: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    required: true,
  },
  movie: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Movie',
    required: true,
  },
  episodeId: {
    type: String,
    default: null,
  },
  progress: {
    type: Number,
    required: true,
    min: 0.0,
    max: 1.0,
    default: 0.0,
  },
  watchedTime: {
    type: Number, // In seconds
    required: true,
    default: 0,
  },
  watchPercentage: {
    type: Number,
    default: 0,
  },
  lastPosition: {
    type: Number,
    default: 0,
  },
  lastWatchedDate: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('History', HistorySchema);
