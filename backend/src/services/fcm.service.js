const fs = require('fs');
const path = require('path');

let admin = null;
const serviceAccountPath = path.join(__dirname, '../config/firebase-service-account.json');

if (fs.existsSync(serviceAccountPath)) {
  try {
    admin = require('firebase-admin');
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log('🔥 Firebase Admin SDK initialized successfully!');
  } catch (error) {
    console.error('🔴 Failed to initialize Firebase Admin SDK:', error);
    admin = null;
  }
} else {
  console.warn('⚠️ Firebase Cloud Messaging config file not found. Push notifications will run in SIMULATED mode.');
}

exports.sendPushNotification = async (token, payload) => {
  if (!token) return false;
  
  const message = {
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: payload.data || {},
    token: token,
  };

  if (admin) {
    try {
      const response = await admin.messaging().send(message);
      console.log('🚀 FCM Notification sent successfully:', response);
      return true;
    } catch (error) {
      console.error('🔴 Failed to send FCM Notification:', error);
      return false;
    }
  } else {
    console.log(`[SIMULATED PUSH NOTIFICATION]
    To Token: ${token}
    Title: ${payload.title}
    Body: ${payload.body}
    Data: ${JSON.stringify(payload.data || {})}
    Status: Emitted successfully (Simulation)`);
    return true;
  }
};

exports.broadcastNotification = async (payload) => {
  const message = {
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: payload.data || {},
    topic: 'all_users',
  };

  if (admin) {
    try {
      const response = await admin.messaging().send(message);
      console.log('🚀 FCM Broadcast sent successfully:', response);
      return true;
    } catch (error) {
      console.error('🔴 Failed to send FCM Broadcast:', error);
      return false;
    }
  } else {
    console.log(`[SIMULATED PUSH BROADCAST]
    Topic: all_users
    Title: ${payload.title}
    Body: ${payload.body}
    Data: ${JSON.stringify(payload.data || {})}
    Status: Emitted successfully (Simulation)`);
    return true;
  }
};
