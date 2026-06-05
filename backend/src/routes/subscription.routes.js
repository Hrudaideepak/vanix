const express = require('express');
const router = express.Router();
const {
  getPlans,
  initiateCheckout,
  verifyPayment,
} = require('../controllers/subscription.controller');
const { protect } = require('../middlewares/auth.middleware');

// Public plans list
router.get('/plans', getPlans);

// Private checkout endpoints
router.post('/checkout', protect, initiateCheckout);
router.post('/verify-payment', protect, verifyPayment);

module.exports = router;
