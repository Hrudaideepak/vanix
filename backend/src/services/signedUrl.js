const AWS = require('aws-cloudfront-sign');
const fs = require('fs');

let privateKey = null;

function getPrivateKey() {
  if (privateKey !== null) return privateKey;
  
  const keyPath = process.env.CLOUDFRONT_PRIVATE_KEY_PATH;
  if (!keyPath) {
    return null;
  }
  
  try {
    privateKey = fs.readFileSync(keyPath, 'utf8');
    return privateKey;
  } catch (err) {
    console.warn(`⚠️ Could not read CloudFront private key file at ${keyPath}:`, err.message);
    return null;
  }
}

function generateSignedUrl(s3Key) {
  const domain = process.env.CLOUDFRONT_DOMAIN;
  const keyPairId = process.env.CLOUDFRONT_KEY_PAIR_ID;
  const keyString = getPrivateKey();
  
  if (!domain || !keyPairId || !keyString) {
    const bucketName = process.env.S3_BUCKET_NAME || 'vanix-videos';
    return domain ? `${domain}/${s3Key}` : `https://${bucketName}.s3.amazonaws.com/${s3Key}`;
  }
  
  const url = `${domain}/${s3Key}`;
  const options = {
    keypairId: keyPairId,
    privateKeyString: keyString,
    expireTime: Math.floor(Date.now() / 1000) + 3600, // 1 hour expiry
  };
  
  try {
    return AWS.getSignedUrl(url, options);
  } catch (err) {
    console.error('❌ Error generating signed CloudFront URL:', err.message);
    return url;
  }
}

module.exports = { generateSignedUrl };
