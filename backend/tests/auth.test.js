const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/user.model');
const Profile = require('../src/models/profile.model');

// Mock Mongo connection for local test run if mongo isn't active
beforeAll(async () => {
  const MONGO_TEST_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/vanix_test';
  await mongoose.connect(MONGO_TEST_URI);
});

afterAll(async () => {
  await mongoose.connection.db.dropDatabase();
  await mongoose.connection.close();
});

beforeEach(async () => {
  await User.deleteMany();
  await Profile.deleteMany();
});

describe('🔐 Auth API Integration Tests', () => {
  
  test('POST /api/register - Should register a new user and create default profile', async () => {
    const res = await request(app)
      .post('/api/register')
      .send({
        email: 'test_jest@vanix.com',
        password: 'securePassword123',
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.accessToken).toBeDefined();
    expect(res.body.user.email).toBe('test_jest@vanix.com');
    expect(res.body.user.profiles.length).toBe(1);
    expect(res.body.user.profiles[0].name).toBe('Default User');
  });

  test('POST /api/login - Should login existing user and return tokens', async () => {
    // Manually register user first
    const email = 'user_login_test@vanix.com';
    const password = 'securePassword123';
    
    await request(app)
      .post('/api/register')
      .send({ email, password });

    // Try Login
    const res = await request(app)
      .post('/api/login')
      .send({ email, password });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.accessToken).toBeDefined();
    expect(res.body.refreshToken).toBeDefined();
  });

  test('POST /api/login - Should fail with wrong password', async () => {
    const email = 'user_login_fail@vanix.com';
    const password = 'securePassword123';

    await request(app)
      .post('/api/register')
      .send({ email, password });

    const res = await request(app)
      .post('/api/login')
      .send({ email, password: 'wrongPassword123' });

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
  });
});
