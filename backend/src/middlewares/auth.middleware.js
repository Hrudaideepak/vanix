const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const env = require('../config/env');
const User = require('../models/user.model');

// Protect Routes
exports.protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    // Set token from Bearer token in header
    token = req.headers.authorization.split(' ')[1];
  }

  // Make sure token exists
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access denied. Authorization token required.',
    });
  }

  try {
    // Verify token
    const decoded = jwt.verify(token, env.JWT_SECRET);

    // Find User
    req.user = await User.findById(decoded.id);
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authorization failed. User profile no longer exists.',
      });
    }

    // Restrict access immediately if banned
    if (req.user.isBanned) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Your account has been restricted by system security policies.',
      });
    }

    // Resolve active profile if profile ID header is supplied
    const profileId = req.headers['x-profile-id'];
    if (profileId && mongoose.Types.ObjectId.isValid(profileId)) {
      // Prevent IDOR by ensuring the profile belongs to the authenticated user
      const isProfileOwnedByUser = req.user.profiles.some(p => p.toString() === profileId);

      if (!isProfileOwnedByUser) {
        return res.status(403).json({
          success: false,
          message: 'Access denied. You do not have permission to access this profile.',
        });
      }

      const Profile = require('../models/profile.model');
      req.profile = await Profile.findById(profileId);
    }

    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired',
        code: 'TOKEN_EXPIRED',
      });
    }
    return res.status(401).json({
      success: false,
      message: 'Invalid access token authorization.',
    });
  }
};

// Grant access to specific roles
exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `User role (${req.user?.role || 'none'}) is not authorized to access this resource`,
      });
    }
    next();
  };
};
