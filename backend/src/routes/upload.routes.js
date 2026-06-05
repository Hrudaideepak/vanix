const express = require('express');
const router = express.Router();
const { uploadMovie, uploadSeries } = require('../controllers/upload.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

// Secure all upload routes with JWT and Admin checks
router.use(protect);
router.use(authorize('admin', 'super-admin'));

router.post('/uploadMovie', uploadMovie);
router.post('/uploadSeries', uploadSeries);

module.exports = router;
