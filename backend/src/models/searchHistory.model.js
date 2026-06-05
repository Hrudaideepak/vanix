const mongoose = require('mongoose');

const SearchHistorySchema = new mongoose.Schema({
  profile: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    required: true,
  },
  query: {
    type: String,
    required: true,
    trim: true,
  },
  searchedAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

SearchHistorySchema.index({ profile: 1, searchedAt: -1 });

module.exports = mongoose.model('SearchHistory', SearchHistorySchema);
