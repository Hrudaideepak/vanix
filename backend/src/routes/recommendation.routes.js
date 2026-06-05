const express = require('express');
const router = express.Router();
const {
  getHomeRecommendations,
  getSimilarContent,
} = require('../controllers/recommendation.controller');
const { protect } = require('../middlewares/auth.middleware');

router.get('/recommendations', protect, getHomeRecommendations);
router.get('/movie/:id/similar', protect, getSimilarContent);

module.exports = router;
