const request = require('supertest');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const app = require('../src/app');
const User = require('../src/models/user.model');
const Profile = require('../src/models/profile.model');
const Movie = require('../src/models/movie.model');

beforeAll(async () => {
  const baseUri = process.env.MONGO_URI || 'mongodb://localhost:27017';
  const url = new URL(baseUri);
  url.pathname = '/test-enterprise';
  const MONGO_TEST_URI = url.toString();
  await mongoose.connect(MONGO_TEST_URI);
});

afterAll(async () => {
  await mongoose.connection.db.dropDatabase();
  await mongoose.connection.close();
});

beforeEach(async () => {
  await User.deleteMany();
  await Profile.deleteMany();
  await Movie.deleteMany();
});

describe('🌌 Enterprise OTT Features Integration Tests', () => {
  
  test('Profiles CRUD and header isolation', async () => {
    // Manually register user first to have valid JWT
    const email = 'test_ent@vanix.com';
    const password = 'securePassword123';

    const regRes = await request(app)
      .post('/api/register')
      .send({ email, password });
    
    const token = regRes.body.accessToken;

    const createRes = await request(app)
      .post('/api/profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'Kids Space', isKids: true, pin: '1234' });
    
    expect(createRes.statusCode).toBe(201);
    expect(createRes.body.success).toBe(true);
    expect(createRes.body.data.isKids).toBe(true);
    expect(createRes.body.data.pin).toBe('1234');

    const kidsProfileId = createRes.body.data._id;

    const getRes = await request(app)
      .get('/api/profiles')
      .set('Authorization', `Bearer ${token}`);
    
    expect(getRes.body.count).toBe(2);

    const updateRes = await request(app)
      .put(`/api/profiles/${kidsProfileId}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ languagePreference: 'te' });
    
    expect(updateRes.body.data.languagePreference).toBe('te');
  });

  test('Fuzzy Search and Typo tolerance matching', async () => {
    await Movie.create({
      title: 'Nebula Genesis',
      description: 'Sci-fi cosmic movie',
      thumbnailUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=500',
      bannerUrl: 'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?w=1000',
      videoUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
      releaseYear: 2024,
      duration: '2h 15m',
      genres: ['Sci-Fi'],
    });

    const regRes = await request(app)
      .post('/api/register')
      .send({ email: 'test_search@vanix.com', password: 'securePassword123' });
    
    const token = regRes.body.accessToken;

    const searchRes = await request(app)
      .get('/api/search/query?q=Nebula')
      .set('Authorization', `Bearer ${token}`);
    
    expect(searchRes.body.count).toBe(1);
    expect(searchRes.body.data[0].title).toBe('Nebula Genesis');

    const typoRes = await request(app)
      .get('/api/search/query?q=Nebla')
      .set('Authorization', `Bearer ${token}`);
    
    expect(typoRes.body.typoCorrected).toBe(true);
    expect(typoRes.body.data[0].title).toBe('Nebula Genesis');
  });
});
