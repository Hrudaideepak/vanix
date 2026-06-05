const express = require('express');
const router = express.Router();
const {
  getWatchlist,
  addToWatchlist,
  removeFromWatchlist,
} = require('../controllers/watchlist.controller');
const { protect } = require('../middlewares/auth.middleware');

// Secure all watchlist routes
router.use(protect);

router.get('/watchlist', getWatchlist);
router.post('/watchlist', addToWatchlist);
router.delete('/watchlist/:id', removeFromWatchlist);

module.exports = router;
