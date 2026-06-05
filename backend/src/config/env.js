const dotenv = require('dotenv');
const path = require('path');

// Load environment variables from .env file
dotenv.config({ path: path.join(__dirname, '../../.env') });

module.exports = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: process.env.PORT || 5000,
  MONGO_URI: process.env.MONGO_URI || 'mongodb://localhost:27017/vanix',
  JWT_SECRET: process.env.JWT_SECRET || 'vanix_super_secret_jwt_key_12345!',
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || 'vanix_super_secret_refresh_jwt_key_54321!',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '15m',
  JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME || 'vanix-cloud',
  CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY || 'cloudinary_key',
  CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET || 'cloudinary_secret',
  RAZORPAY_KEY_ID: process.env.RAZORPAY_KEY_ID || 'rzp_test_key_id',
  RAZORPAY_KEY_SECRET: process.env.RAZORPAY_KEY_SECRET || 'rzp_test_key_secret',
};
