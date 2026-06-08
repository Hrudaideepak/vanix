const User = require('../models/user.model');
const env = require('../config/env');
const crypto = require('crypto');

// Mock plans list matches AppConstants on mobile
const billingPlans = [
  { id: 'free', name: 'Free Tier', price: 0, durationDays: 9999 },
  { id: 'silver', name: 'Silver Tier', price: 199, durationDays: 30 },
  { id: 'gold', name: 'Gold Tier', price: 499, durationDays: 90 },
  { id: 'premium', name: 'Premium Tier', price: 999, durationDays: 365 },
];

// @desc    Get subscription billing plans list
// @route   GET /api/plans
// @access  Public
exports.getPlans = (req, res, next) => {
  res.status(200).json({
    success: true,
    data: billingPlans,
  });
};

// @desc    Initiate Razorpay / Payment Gateway checkout order
// @route   POST /api/checkout
// @access  Private
exports.initiateCheckout = async (req, res, next) => {
  try {
    const { planId } = req.body;
    const plan = billingPlans.find(p => p.id === planId);

    if (!plan) {
      return res.status(400).json({ success: false, message: 'Invalid plan selection' });
    }

    // Production Razorpay integration would instantiate client and call orders.create.
    // For local running, we generate a mock Razorpay Order Object.
    const mockOrderId = `order_rzp_${crypto.randomBytes(8).toString('hex')}`;

    res.status(200).json({
      success: true,
      orderId: mockOrderId,
      amount: plan.price * 100, // Amount in paise/cents
      currency: 'INR',
      keyId: env.RAZORPAY_KEY_ID,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Verify payment signature and activate subscription
// @route   POST /api/verify-payment
// @access  Private
exports.verifyPayment = async (req, res, next) => {
  try {
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature, planId } = req.body;

    if (!razorpayOrderId || !planId) {
      return res.status(400).json({ success: false, message: 'Missing transaction logs credentials' });
    }

    // Verify Razorpay HMAC signature
    const isMockMode = env.RAZORPAY_KEY_SECRET === 'rzp_test_key_secret' || env.RAZORPAY_KEY_SECRET === 'rzp_test_your_key_secret' || !razorpaySignature;

    if (isMockMode) {
      console.warn('⚠️ Running in simulated Razorpay mode. Bypassing cryptographic signature verification.');
    } else {
      const body = razorpayOrderId + "|" + razorpayPaymentId;
      const expectedSignature = crypto
        .createHmac('sha256', env.RAZORPAY_KEY_SECRET)
        .update(body.toString())
        .digest('hex');

      if (expectedSignature !== razorpaySignature) {
        return res.status(400).json({ success: false, message: 'Invalid payment signature. Transaction verification failed.' });
      }
    }
    
    // Auto-activate plan
    const plan = billingPlans.find(p => p.id === planId);
    if (!plan) {
      return res.status(400).json({ success: false, message: 'Plan no longer active' });
    }

    // Calculate expiration date
    const expiresDate = new Date();
    expiresDate.setDate(expiresDate.getDate() + plan.durationDays);

    // Update user subscription state
    const user = await User.findById(req.user.id);
    user.subscriptionPlan = plan.id;
    user.subscriptionExpires = expiresDate;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Payment verified. Subscription active!',
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        subscriptionPlan: user.subscriptionPlan,
        subscriptionExpires: user.subscriptionExpires,
      },
    });
  } catch (error) {
    next(error);
  }
};
