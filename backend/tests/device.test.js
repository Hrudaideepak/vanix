const { remoteLogout } = require('../src/controllers/device.controller');
const User = require('../src/models/user.model');

jest.mock('../src/models/user.model');

describe('Device Controller - remoteLogout', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 'user123' },
      params: { deviceId: 'device456' }
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
