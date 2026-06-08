const { remoteLogout, getActiveDevices, updateFCMToken } = require('../src/controllers/device.controller');
const User = require('../src/models/user.model');
const fcm = require('../src/services/fcm.service');

jest.mock('../src/models/user.model');
jest.mock('../src/services/fcm.service');

describe('Device Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 'user123' },
      params: {},
      body: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getActiveDevices', () => {
    test('should get active devices and return 200', async () => {
      const mockUser = {
        devices: [
          { deviceId: 'device456' },
          { deviceId: 'device789' }
        ]
      };
      User.findById.mockResolvedValue(mockUser);

      await getActiveDevices(req, res, next);

      expect(User.findById).toHaveBeenCalledWith('user123');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        count: 2,
        data: mockUser.devices
      });
    });

    test('should call next with error if something goes wrong', async () => {
      const error = new Error('Database error');
      User.findById.mockRejectedValue(error);

      await getActiveDevices(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('remoteLogout', () => {
    beforeEach(() => {
      req.params = { deviceId: 'device456' };
    });

    test('should remotely logout device and return 200', async () => {
      const mockUser = {
        devices: [
          { deviceId: 'device456' },
          { deviceId: 'device789' }
        ],
        save: jest.fn().mockResolvedValue(true)
      };
      User.findById.mockResolvedValue(mockUser);

      await remoteLogout(req, res, next);

      expect(User.findById).toHaveBeenCalledWith('user123');
      expect(mockUser.devices).toHaveLength(1);
      expect(mockUser.devices[0].deviceId).toBe('device789');
      expect(mockUser.save).toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Device successfully logged out remotely'
      });
    });

    test('should return 404 if device not found', async () => {
      const mockUser = {
        devices: [
          { deviceId: 'device789' }
        ],
        save: jest.fn()
      };
      User.findById.mockResolvedValue(mockUser);

      await remoteLogout(req, res, next);

      expect(User.findById).toHaveBeenCalledWith('user123');
      expect(mockUser.devices).toHaveLength(1);
      expect(mockUser.save).not.toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Device registration not found'
      });
    });

    test('should call next with error if something goes wrong', async () => {
      const error = new Error('Database error');
      User.findById.mockRejectedValue(error);

      await remoteLogout(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateFCMToken', () => {
    test('should return 400 if deviceId or fcmToken is missing', async () => {
      req.body = { deviceId: 'device456' }; // missing fcmToken
      await updateFCMToken(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Please provide deviceId and fcmToken'
      });

      req.body = { fcmToken: 'token456' }; // missing deviceId
      await updateFCMToken(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Please provide deviceId and fcmToken'
      });
    });

    test('should return 404 if device not found', async () => {
      req.body = { deviceId: 'device456', fcmToken: 'token456' };
      const mockUser = {
        devices: [
          { deviceId: 'device789' }
        ]
      };
      User.findById.mockResolvedValue(mockUser);

      await updateFCMToken(req, res, next);

      expect(User.findById).toHaveBeenCalledWith('user123');
      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Device registration not found. Authenticate this device first.'
      });
    });

    test('should update FCM token and return 200', async () => {
      req.body = { deviceId: 'device456', fcmToken: 'token456' };
      const mockUser = {
        devices: [
          { deviceId: 'device456', fcmToken: 'oldToken', lastActive: new Date('2020-01-01') }
        ],
        save: jest.fn().mockResolvedValue(true)
      };
      User.findById.mockResolvedValue(mockUser);
      fcm.sendPushNotification.mockResolvedValue(true);

      await updateFCMToken(req, res, next);

      expect(User.findById).toHaveBeenCalledWith('user123');
      expect(mockUser.devices[0].fcmToken).toBe('token456');
      expect(mockUser.devices[0].lastActive.getTime()).toBeGreaterThan(new Date('2020-01-01').getTime());
      expect(mockUser.save).toHaveBeenCalled();
      expect(fcm.sendPushNotification).toHaveBeenCalledWith('token456', {
        title: '🌌 Welcome to VANIX!',
        body: 'Your device is now synchronized for cinematic push notifications.',
        data: { type: 'registration_confirm' }
      });
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'FCM push token registered successfully'
      });
    });

    test('should call next with error if something goes wrong', async () => {
      req.body = { deviceId: 'device456', fcmToken: 'token456' };
      const error = new Error('Database error');
      User.findById.mockRejectedValue(error);

      await updateFCMToken(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
