const express = require('express');
const router = express.Router();
const { getAdminAnalytics } = require('../controllers/analytics.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.get('/analytics', protect, authorize('admin', 'super-admin'), getAdminAnalytics);

module.exports = router;
