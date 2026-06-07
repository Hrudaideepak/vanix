const express = require('express');
const router = express.Router();
const { uploadMovie, uploadSeries } = require('../controllers/upload.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.post('/uploadMovie', protect, authorize('admin', 'super-admin'), uploadMovie);
router.post('/uploadSeries', protect, authorize('admin', 'super-admin'), uploadSeries);

module.exports = router;
