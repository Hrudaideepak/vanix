const User = require('../models/user.model');

exports.getActiveDevices = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    res.status(200).json({
      success: true,
      count: user.devices.length,
      data: user.devices,
    });
  } catch (error) {
    next(error);
  }
};

exports.remoteLogout = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    
    const initialLen = user.devices.length;
    user.devices = user.devices.filter(d => d.deviceId !== req.params.deviceId);
    
    if (user.devices.length === initialLen) {
      return res.status(404).json({ success: false, message: 'Device registration not found' });
    }

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Device successfully logged out remotely',
    });
  } catch (error) {
    next(error);
  }
};

exports.updateFCMToken = async (req, res, next) => {
  try {
    const { deviceId, fcmToken } = req.body;

    if (!deviceId || !fcmToken) {
      return res.status(400).json({ success: false, message: 'Please provide deviceId and fcmToken' });
    }

    const user = await User.findById(req.user.id);
    const deviceIdx = user.devices.findIndex(d => d.deviceId === deviceId);

    if (deviceIdx !== -1) {
      user.devices[deviceIdx].fcmToken = fcmToken;
      user.devices[deviceIdx].lastActive = new Date();
      await user.save();

      // Trigger a test welcome notification to verify the FCM integration
      const fcm = require('../services/fcm.service');
      await fcm.sendPushNotification(fcmToken, {
        title: '🌌 Welcome to VANIX!',
        body: 'Your device is now synchronized for cinematic push notifications.',
        data: { type: 'registration_confirm' }
      });

      return res.status(200).json({
        success: true,
        message: 'FCM push token registered successfully',
      });
    } else {
      return res.status(404).json({
        success: false,
        message: 'Device registration not found. Authenticate this device first.',
      });
    }
  } catch (error) {
    next(error);
  }
};
