const { getHomeRecommendations } = require('../src/controllers/recommendation.controller');
const History = require('../src/models/history.model');
const Movie = require('../src/models/movie.model');

jest.mock('../src/models/history.model');
jest.mock('../src/models/movie.model');

describe('Recommendation Controller', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should return 400 if no profile is in request', async () => {
    const req = {};
    const res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    const next = jest.fn();

    await getHomeRecommendations(req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Profile header x-profile-id is required' });
  });

  it('should return home recommendations successfully', async () => {
    const req = { profile: { _id: 'profileId', isKids: false } };
    const res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    const next = jest.fn();

    // Mock history
    History.find.mockReturnValue({
      populate: jest.fn().mockReturnThis(),
      sort: jest.fn().mockReturnThis(),
      limit: jest.fn().mockResolvedValue([])
    });

    // Mock movies for fallback becauseYouWatched
    Movie.find.mockReturnValue({
      sort: jest.fn().mockReturnThis(),
      limit: jest.fn().mockResolvedValue([{ title: 'SciFi Movie' }])
    });

    await getHomeRecommendations(req, res, next);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
      success: true,
      data: expect.any(Object)
    }));
  });
});
