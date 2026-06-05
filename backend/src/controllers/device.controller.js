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
