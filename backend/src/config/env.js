const dotenv = require('dotenv');
const path = require('path');
const crypto = require('crypto');

// Load environment variables from .env file
dotenv.config({ path: path.join(__dirname, '../../.env') });

const requireEnv = (key) => {
  if (process.env[key]) return process.env[key];
  if (process.env.NODE_ENV === 'test') {
      return crypto.createHash('sha256').update(key).digest('hex'); // consistent dummy secret for tests
  }
  throw new Error(`CRITICAL ERROR: Environment variable ${key} is not set in .env file! This is a severe security risk.`);
};

module.exports = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: process.env.PORT || 5000,
  MONGO_URI: process.env.MONGO_URI || 'mongodb://localhost:27017/vanix',
  JWT_SECRET: requireEnv('JWT_SECRET'),
  JWT_REFRESH_SECRET: requireEnv('JWT_REFRESH_SECRET'),
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '15m',
  JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME || 'vanix-cloud',
  CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY || 'cloudinary_key',
  CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET || 'cloudinary_secret',
  RAZORPAY_KEY_ID: process.env.RAZORPAY_KEY_ID || 'rzp_test_key_id',
  RAZORPAY_KEY_SECRET: process.env.RAZORPAY_KEY_SECRET || 'rzp_test_key_secret',
  REDIS_HOST: process.env.REDIS_HOST || 'localhost',
  REDIS_PORT: process.env.REDIS_PORT || 6379,
  AWS_ACCESS_KEY_ID: process.env.AWS_ACCESS_KEY_ID,
  AWS_SECRET_ACCESS_KEY: process.env.AWS_SECRET_ACCESS_KEY,
  AWS_REGION: process.env.AWS_REGION || 'us-east-1',
  S3_ENDPOINT: process.env.S3_ENDPOINT,
  S3_BUCKET_NAME: process.env.S3_BUCKET_NAME,
  CLOUDFRONT_DOMAIN: process.env.CLOUDFRONT_DOMAIN,
  CLOUDFRONT_KEY_PAIR_ID: process.env.CLOUDFRONT_KEY_PAIR_ID,
  CLOUDFRONT_PRIVATE_KEY_PATH: process.env.CLOUDFRONT_PRIVATE_KEY_PATH,
  TEMP_VIDEO_PATH: process.env.TEMP_VIDEO_PATH || './temp/uploads',
  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || 'google_client_id_placeholder',
};
