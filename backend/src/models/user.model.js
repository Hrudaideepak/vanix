const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const env = require('../config/env');

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Please provide an email address'],
    unique: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please add a valid email address',
    ],
    lowercase: true,
    trim: true,
  },
  password: {
    type: String,
    required: function() { return !this.googleId; }, // Required only if not google login
    minlength: 6,
    select: false, // Don't return password in query responses by default
  },
  googleId: {
    type: String,
    sparse: true, // Allow multiple null values for unique index if we add one later
  },
  role: {
    type: String,
    enum: ['user', 'moderator', 'admin', 'super-admin'],
    default: 'user',
  },
  subscriptionPlan: {
    type: String,
    enum: ['free', 'silver', 'gold', 'premium'],
    default: 'free',
  },
  subscriptionExpires: {
    type: Date,
    default: null,
  },
  profiles: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
  }],
  devices: [{
    deviceId: { type: String, required: true },
    deviceName: { type: String, default: 'Unknown Device' },
    token: { type: String },
    fcmToken: { type: String },
    lastActive: { type: Date, default: Date.now },
  }],
  isBanned: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

// Encrypt password using bcrypt
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    return next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Match user entered password to hashed password in database
UserSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Sign Access Token
UserSchema.methods.generateAccessToken = function() {
  return jwt.sign(
    { id: this._id, role: this.role },
    env.JWT_SECRET,
    { expiresIn: env.JWT_EXPIRES_IN }
  );
};

// Sign Refresh Token
UserSchema.methods.generateRefreshToken = function() {
  return jwt.sign(
    { id: this._id },
    env.JWT_REFRESH_SECRET,
    { expiresIn: env.JWT_REFRESH_EXPIRES_IN }
  );
};

module.exports = mongoose.model('User', UserSchema);
