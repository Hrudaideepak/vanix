const crypto = require('crypto');
const env = require('../config/env');

/**
 * Generate a signed video streaming URL with expiration for anti-piracy protection.
 * @param {string} videoUrl - The original storage or source video link.
 * @returns {string} - Expiring signed URL containing HMAC access token.
 */
exports.generateSignedStreamingUrl = (videoUrl) => {
  if (!videoUrl) return '';
  if (videoUrl.includes('signedToken=')) return videoUrl; // Already signed

  try {
    const parsedUrl = new URL(videoUrl);
    
    // Set link expiration to 2 hours from now
    const expires = Math.floor(Date.now() / 1000) + (2 * 60 * 60);
    
    // Construct signing payload
    const payload = `${parsedUrl.pathname}?expires=${expires}`;
    
    // Sign using SHA256 HMAC and JWT Secret key
    const signature = crypto
      .createHmac('sha256', env.JWT_SECRET)
      .update(payload)
      .digest('hex');

    // Append security query params
    parsedUrl.searchParams.set('expires', expires.toString());
    parsedUrl.searchParams.set('signedToken', signature);

    return parsedUrl.toString();
  } catch (error) {
    // If URL parsing fails, return original URL
    return videoUrl;
  }
};

/**
 * Verify a signed streaming request.
 * @param {string} fullUrl - The requested stream link with query params.
 * @returns {boolean} - True if signature is valid and not expired.
 */
exports.verifySignedStream = (fullUrl) => {
  try {
    const parsedUrl = new URL(fullUrl);
    const expires = parseInt(parsedUrl.searchParams.get('expires'));
    const signedToken = parsedUrl.searchParams.get('signedToken');

    if (!expires || !signedToken) return false;

    // Check expiration
    if (Math.floor(Date.now() / 1000) > expires) {
      return false; // Expired link
    }

    // Reconstruct payload and signature
    parsedUrl.searchParams.delete('signedToken');
    const payload = `${parsedUrl.pathname}?expires=${expires}`;
    
    const expectedSignature = crypto
      .createHmac('sha256', env.JWT_SECRET)
      .update(payload)
      .digest('hex');

    return signedToken === expectedSignature;
  } catch (_) {
    return false;
  }
};
