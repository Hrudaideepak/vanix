const express = require('express');
const router = express.Router();
const {
  getHistory,
  saveHistory,
} = require('../controllers/history.controller');
const { protect } = require('../middlewares/auth.middleware');

// Secure all history routes
router.use(protect);

router.get('/history', getHistory);
router.post('/history', saveHistory);

module.exports = router;
