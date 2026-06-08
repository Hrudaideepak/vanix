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

// ⚡ Bolt Performance Optimization: Added compound indexes
// Why: History queries are run frequently (home page load, saving progress).
// Impact: Reduces O(N) full collection scans to O(1) indexed lookups, significantly improving read times as the history collection grows.
// Measure: Monitor query execution time for home recommendations and save progress endpoints.
HistorySchema.index({ profile: 1, lastWatchedDate: -1 });
HistorySchema.index({ profile: 1, movie: 1, episodeId: 1 });
HistorySchema.index({ user: 1, updatedAt: -1 });

module.exports = mongoose.model('History', HistorySchema);
