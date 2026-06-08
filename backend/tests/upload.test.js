const { uploadMovie, uploadSeries } = require('../src/controllers/upload.controller');
const Movie = require('../src/models/movie.model');

// Mock dependencies
jest.mock('../src/models/movie.model');
jest.mock('../src/services/ffmpeg.service', () => ({
  processVideoPipeline: jest.fn().mockResolvedValue({
    hlsUrl: 'hls-url',
    resolutions: {},
    trailerUrl: 'trailer-url',
    thumbnailUrl: 'thumbnail-url',
    previewImages: []
  })
}));

describe('Upload Controller Unit Tests', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      body: {
        title: 'Test Title',
        description: 'Test Description',
        videoUrl: 'http://example.com/video.mp4',
        releaseYear: 2024,
        duration: '120 min',
        genres: 'Action, Drama'
      }
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    Movie.create.mockClear();
  });

  test('uploadMovie calls Movie.create with type: "movie"', async () => {
    Movie.create.mockResolvedValue({ _id: '123', type: 'movie' });
    await uploadMovie(req, res, next);
    expect(Movie.create).toHaveBeenCalled();
    const createArgs = Movie.create.mock.calls[0][0];
    expect(createArgs.type).toBe('movie');
    expect(res.status).toHaveBeenCalledWith(201);
  });

  test('uploadSeries calls Movie.create with type: "series"', async () => {
    Movie.create.mockResolvedValue({ _id: '456', type: 'series' });
    await uploadSeries(req, res, next);
    expect(Movie.create).toHaveBeenCalled();
    const createArgs = Movie.create.mock.calls[0][0];
    expect(createArgs.type).toBe('series');
    expect(res.status).toHaveBeenCalledWith(201);
  });

  test('returns 400 if required fields are missing', async () => {
      req.body.title = null;
      await uploadMovie(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Missing required media details fields' });
  });
});
