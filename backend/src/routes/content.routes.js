const express = require('express');
const router = express.Router();
const {
  getMovies,
  getMovieById,
  getCategories,
  searchContent,
  deleteMovie,
} = require('../controllers/content.controller');

const { protect, authorize } = require('../middlewares/auth.middleware');

router.get('/movies', protect, getMovies);
router.get('/movie/:id', protect, getMovieById);
router.delete('/movie/:id', protect, authorize('admin', 'super-admin'), deleteMovie);
router.get('/categories', protect, getCategories);
router.get('/search', protect, searchContent);

module.exports = router;
