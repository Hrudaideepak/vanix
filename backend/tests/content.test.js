const { searchContent } = require('../src/controllers/content.controller');
const Movie = require('../src/models/movie.model');

jest.mock('../src/models/movie.model');

describe('Content Controller - searchContent', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      query: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  it('should search with properly escaped regex characters to prevent ReDoS', async () => {
    req.query.q = 'test+*?^$()[]{}|\\';

    const mockResults = [{ title: 'test movie' }];
    const mockLimit = jest.fn().mockResolvedValue(mockResults);
    Movie.find.mockReturnValue({ limit: mockLimit });

    await searchContent(req, res, next);

    expect(Movie.find).toHaveBeenCalledWith({
      $or: [
        { title: { $regex: 'test\\+\\*\\?\\^\\$\\(\\)\\[\\]\\{\\}\\|\\\\', $options: 'i' } },
        { description: { $regex: 'test\\+\\*\\?\\^\\$\\(\\)\\[\\]\\{\\}\\|\\\\', $options: 'i' } }
      ]
    });
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      count: 1,
      data: mockResults
    });
  });

  it('should search with normal text', async () => {
    req.query.q = 'normal search';

    const mockResults = [{ title: 'normal search movie' }];
    const mockLimit = jest.fn().mockResolvedValue(mockResults);
    Movie.find.mockReturnValue({ limit: mockLimit });

    await searchContent(req, res, next);

    expect(Movie.find).toHaveBeenCalledWith({
      $or: [
        { title: { $regex: 'normal search', $options: 'i' } },
        { description: { $regex: 'normal search', $options: 'i' } }
      ]
    });
    expect(res.status).toHaveBeenCalledWith(200);
  });
});
