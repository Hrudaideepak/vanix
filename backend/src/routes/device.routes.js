const express = require('express');
const router = express.Router();
const { getActiveDevices, remoteLogout } = require('../controllers/device.controller');
const { protect } = require('../middlewares/auth.middleware');

router.use(protect);

router.get('/devices', getActiveDevices);
router.delete('/devices/:deviceId', remoteLogout);

module.exports = router;
