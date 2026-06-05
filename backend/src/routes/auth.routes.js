const express = require('express');
const router = express.Router();
const {
  register,
  login,
  refreshToken,
  googleLogin,
  getProfile,
  getAllUsers,
  toggleUserBan,
} = require('../controllers/auth.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

// Public endpoints
router.post('/register', register);
router.post('/login', login);
router.post('/refresh-token', refreshToken);
router.post('/google-login', googleLogin);

// Protected endpoints
router.get('/profile', protect, getProfile);

// Admin-only endpoints
router.get('/users', protect, authorize('admin', 'super-admin'), getAllUsers);
router.put('/users/:id/ban', protect, authorize('admin', 'super-admin'), toggleUserBan);

// Mock logout endpoint (Client invalidates token locally, backend logs out by blacklisting if needed or simple response)
router.post('/logout', (req, res) => {
  res.status(200).json({ success: true, message: 'Successfully logged out session' });
});

module.exports = router;
