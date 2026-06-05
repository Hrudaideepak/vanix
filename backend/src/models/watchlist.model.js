const mongoose = require('mongoose');

const WatchlistSchema = new mongoose.Schema({
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
}, {
  timestamps: true,
});

// Ensure a profile can only add a movie once to their watchlist
WatchlistSchema.index({ profile: 1, movie: 1 }, { unique: true });

module.exports = mongoose.model('Watchlist', WatchlistSchema);
