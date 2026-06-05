const express = require('express');
const router = express.Router();
const {
  getProfiles,
  createProfile,
  updateProfile,
  deleteProfile,
} = require('../controllers/profile.controller');
const { protect } = require('../middlewares/auth.middleware');

router.use(protect);

router.route('/profiles')
  .get(getProfiles)
  .post(createProfile);

router.route('/profiles/:id')
  .put(updateProfile)
  .delete(deleteProfile);

module.exports = router;
