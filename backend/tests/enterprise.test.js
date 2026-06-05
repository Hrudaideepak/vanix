const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/user.model');
const Profile = require('../src/models/profile.model');
const Movie = require('../src/models/movie.model');

beforeAll(async () => {
  const MONGO_TEST_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/vanix_test_ent';
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
    const regRes = await request(app)
      .post('/api/register')
      .send({ email: 'test_ent@vanix.com', password: 'securePassword123' });
    
    const token = regRes.body.accessToken;
    const defaultProfileId = regRes.body.user.profiles[0]._id;

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
