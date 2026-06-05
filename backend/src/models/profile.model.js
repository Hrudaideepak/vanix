const mongoose = require('mongoose');

const ProfileSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  name: {
    type: String,
    required: [true, 'Please add a profile name'],
    trim: true,
    maxlength: [15, 'Profile name cannot exceed 15 characters'],
  },
  avatarUrl: {
    type: String,
    default: 'https://api.dicebear.com/7.x/bottts/png?seed=Vanix', // Premium visual avatar generator API
  },
  isKids: {
    type: Boolean,
    default: false,
  },
  pin: {
    type: String,
    default: null, // If set, profile requires this 4-digit pin to access
    match: [/^\d{4}$/, 'PIN must be a 4-digit number'],
  },
  watchlist: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Movie', // References movies or series
  }],
  languagePreference: {
    type: String,
    enum: ['en', 'te', 'ta', 'hi'],
    default: 'en',
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Profile', ProfileSchema);
