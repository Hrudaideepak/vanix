const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/user.model');
const Profile = require('../src/models/profile.model');

// Mock Mongo connection for local test run if mongo isnt active
beforeAll(async () => {
  const baseUri = process.env.MONGO_URI 
    ? process.env.MONGO_URI.replace(/\/[^\/]+$/, '') 
    : 'mongodb://localhost:27017';
  const MONGO_TEST_URI = `${baseUri}/vanix_test`;
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

  test('GET /api/users/me - Should fail with 403 when passing x-profile-id that does not belong to user', async () => {
    // 1. Create User A with a profile
    const userA_res = await request(app)
      .post('/api/register')
      .send({ email: 'usera@vanix.com', password: 'password123' });
    const userA_profileId = userA_res.body.user.profiles[0]._id;

    // 2. Create User B with a profile
    const userB_res = await request(app)
      .post('/api/register')
      .send({ email: 'userb@vanix.com', password: 'password123' });
    const userB_token = userB_res.body.accessToken;

    // 3. User B tries to access a protected route using User A's profile ID
    const res = await request(app)
      .get('/api/users/me')
      .set('Authorization', `Bearer ${userB_token}`)
      .set('x-profile-id', userA_profileId);

    expect(res.statusCode).toBe(403);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe('Access denied. You do not have permission to access this profile.');
  });
});
