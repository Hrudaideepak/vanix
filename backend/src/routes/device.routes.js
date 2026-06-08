const express = require('express');
const router = express.Router();
const { getActiveDevices, remoteLogout, updateFCMToken } = require('../controllers/device.controller');
const { protect } = require('../middlewares/auth.middleware');

router.use(protect);

router.get('/devices', getActiveDevices);
router.post('/devices/fcm-token', updateFCMToken);
router.delete('/devices/:deviceId', remoteLogout);

module.exports = router;
