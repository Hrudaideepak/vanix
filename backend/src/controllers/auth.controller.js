const User = require('../models/user.model');
const Profile = require('../models/profile.model');
const jwt = require('jsonwebtoken');
const env = require('../config/env');

const registerDevice = async (user, deviceId, deviceName, token) => {
  if (!deviceId) return;
  
  let limit = 1;
  if (user.subscriptionPlan === 'silver') limit = 2;
  else if (user.subscriptionPlan === 'gold') limit = 4;
  else if (user.subscriptionPlan === 'premium' || user.role === 'admin' || user.role === 'super-admin') limit = 5;

  const existingDeviceIdx = user.devices.findIndex(d => d.deviceId === deviceId);
  
  if (existingDeviceIdx !== -1) {
    user.devices[existingDeviceIdx].lastActive = new Date();
    user.devices[existingDeviceIdx].token = token;
    user.devices[existingDeviceIdx].deviceName = deviceName || user.devices[existingDeviceIdx].deviceName;
  } else {
    if (user.devices.length >= limit) {
      throw new Error(`Device limit reached. Your subscription allows a maximum of ${limit} active devices. Please remote logout from another device.`);
    }
    user.devices.push({
      deviceId,
      deviceName: deviceName || 'Unknown Device',
      token,
      lastActive: new Date(),
    });
  }
  await user.save();
};

// @desc    Register a new user
// @route   POST /api/register
// @access  Public
exports.register = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide email and password' });
    }

    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ success: false, message: 'Email address already registered' });
    }

    // Create user
    const user = await User.create({
      email,
      password,
    });

    // Automatically create a default profile for the user
    const defaultProfile = await Profile.create({
      user: user._id,
      name: 'Default User',
      avatarUrl: `https://api.dicebear.com/7.x/bottts/png?seed=${user._id}`,
      isKids: false,
    });

    // Add profile to user
    user.profiles.push(defaultProfile._id);
    await user.save();

    // Generate tokens
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    // Register active device
    try {
      const { deviceId, deviceName } = req.body;
      await registerDevice(user, deviceId, deviceName, accessToken);
    } catch (deviceError) {
      // Clean up newly created user on login failure to prevent orphan users if device limit errors (shouldn't happen on register, but safe)
      await User.findByIdAndDelete(user._id);
      return res.status(403).json({ success: false, message: deviceError.message });
    }

    res.status(201).json({
      success: true,
      accessToken,
      refreshToken,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        subscriptionPlan: user.subscriptionPlan,
        profiles: [defaultProfile],
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Login user
// @route   POST /api/login
// @access  Public
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide email and password' });
    }

    // Check user in DB
    const user = await User.findOne({ email }).select('+password').populate('profiles');
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Check password match
    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Generate tokens
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    // Register active device
    try {
      const { deviceId, deviceName } = req.body;
      await registerDevice(user, deviceId, deviceName, accessToken);
    } catch (deviceError) {
      return res.status(403).json({ success: false, message: deviceError.message });
    }

    res.status(200).json({
      success: true,
      accessToken,
      refreshToken,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        subscriptionPlan: user.subscriptionPlan,
        profiles: user.profiles,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Refresh access token
// @route   POST /api/refresh-token
// @access  Public
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ success: false, message: 'Refresh token is required' });
    }

    // Verify token
    let decoded;
    try {
      decoded = jwt.verify(refreshToken, env.JWT_REFRESH_SECRET);
    } catch (err) {
      return res.status(401).json({ success: false, message: 'Invalid or expired refresh token' });
    }

    // Find User
    const user = await User.findById(decoded.id).populate('profiles');
    if (!user) {
      return res.status(401).json({ success: false, message: 'User session no longer valid' });
    }

    // Generate new Access Token
    const accessToken = user.generateAccessToken();

    res.status(200).json({
      success: true,
      accessToken,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        subscriptionPlan: user.subscriptionPlan,
        profiles: user.profiles,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Google Sign-in handler (mock OAuth provider flow)
// @route   POST /api/google-login
// @access  Public
exports.googleLogin = async (req, res, next) => {
  try {
    let { googleId, email, name, avatarUrl, idToken } = req.body;

    // Secure Verification Mode if GOOGLE_CLIENT_ID is configured
    if (env.GOOGLE_CLIENT_ID && env.GOOGLE_CLIENT_ID !== 'google_client_id_placeholder') {
      if (!idToken) {
        return res.status(400).json({ success: false, message: 'Google OAuth idToken is required' });
      }
      try {
        const { OAuth2Client } = require('google-auth-library');
        const client = new OAuth2Client(env.GOOGLE_CLIENT_ID);
        const ticket = await client.verifyIdToken({
          idToken,
          audience: env.GOOGLE_CLIENT_ID,
        });
        const payload = ticket.getPayload();
        
        googleId = payload['sub'];
        email = payload['email'];
        name = payload['name'];
        avatarUrl = payload['picture'];
      } catch (verificationError) {
        console.error('Google OAuth ID Token verification failed:', verificationError);
        return res.status(401).json({ success: false, message: 'Google authentication failed. Invalid ID Token.' });
      }
    } else {
      console.warn('⚠️ Google Client ID not configured. Running in Mock Google Login Mode.');
      if (!googleId || !email) {
        return res.status(400).json({ success: false, message: 'Google authentication details incomplete' });
      }
    }

    let user = await User.findOne({ email }).populate('profiles');

    if (!user) {
      // Create google oauth user
      user = await User.create({
        email,
        googleId,
        role: 'user',
      });

      // Default profile
      const defaultProfile = await Profile.create({
        user: user._id,
        name: name || 'Google User',
        avatarUrl: avatarUrl || `https://api.dicebear.com/7.x/bottts/png?seed=${user._id}`,
        isKids: false,
      });

      user.profiles.push(defaultProfile._id);
      await user.save();
      
      // Re-fetch populated user
      user = await User.findById(user._id).populate('profiles');
    }

    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    // Register active device
    try {
      const { deviceId, deviceName } = req.body;
      await registerDevice(user, deviceId, deviceName, accessToken);
    } catch (deviceError) {
      return res.status(403).json({ success: false, message: deviceError.message });
    }

    res.status(200).json({
      success: true,
      accessToken,
      refreshToken,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        subscriptionPlan: user.subscriptionPlan,
        profiles: user.profiles,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get Current User Profile
// @route   GET /api/profile
// @access  Private
exports.getProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).populate('profiles');
    res.status(200).json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        subscriptionPlan: user.subscriptionPlan,
        profiles: user.profiles,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all users for admin list
// @route   GET /api/users
// @access  Private/Admin
exports.getAllUsers = async (req, res, next) => {
  try {
    const users = await User.find({}).select('-password');
    res.status(200).json({
      success: true,
      count: users.length,
      data: users,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Ban or unban user
// @route   PUT /api/users/:id/ban
// @access  Private/Admin
exports.toggleUserBan = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    // Toggle ban state
    user.isBanned = !user.isBanned;
    
    // If banned, clear their active sessions/devices so they are immediately kicked off
    if (user.isBanned) {
      user.devices = [];
    }
    
    await user.save();
    
    res.status(200).json({
      success: true,
      message: `User account is now ${user.isBanned ? 'Banned' : 'Active'}`,
      data: user,
    });
  } catch (error) {
    next(error);
  }
};
