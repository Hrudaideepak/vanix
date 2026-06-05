const express = require('express');
const router = express.Router();
const {
  smartSearch,
  getRecentSearches,
  clearRecentSearches,
  getTrendingSearches,
} = require('../controllers/search.controller');
const { protect } = require('../middlewares/auth.middleware');

router.get('/search/query', protect, smartSearch);
router.get('/search/recent', protect, getRecentSearches);
router.delete('/search/recent', protect, clearRecentSearches);
router.get('/search/trending', getTrendingSearches);

module.exports = router;
