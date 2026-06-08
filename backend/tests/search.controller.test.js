const { smartSearch } = require('../src/controllers/search.controller');
const Movie = require('../src/models/movie.model');

jest.mock('../src/models/movie.model', () => {
  return {
    find: jest.fn()
  };
});
jest.mock('../src/models/searchHistory.model', () => {
  return {
    deleteMany: jest.fn(),
    create: jest.fn(),
    find: jest.fn(),
    aggregate: jest.fn()
  };
});

describe('Search Controller', () => {
  let req;
  let res;
  let next;

  beforeEach(() => {
    req = {
      query: {},
      profile: null
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  it('should safely escape malicious regex characters in search query', async () => {
    // Malicious query containing unescaped regex characters
    req.query.q = '.*+?^${}()|[]\\';

    // We mock Movie.find to return an object with limit method so it doesn't crash
    const mockLimit = jest.fn().mockResolvedValue([]);
    Movie.find.mockReturnValue({ limit: mockLimit });

    await smartSearch(req, res, next);

    // Get the filter object passed to Movie.find
    expect(Movie.find).toHaveBeenCalled();
    const filterCall = Movie.find.mock.calls[0][0];

    // Expecting $or filter with the escaped string inside a RegExp
    expect(filterCall.$or).toBeDefined();

    // We expect the RegExp to be created with the properly escaped string.
    // So the toString() of the RegExp should be: /\.\*\+\?\^\$\{\}\(\)\|\[\]\\/i
    const titleRegex = filterCall.$or[0].title;
    expect(titleRegex.toString()).toBe('/\\.\\*\\+\\?\\^\\$\\{\\}\\(\\)\\|\\[\\]\\\\/i');
  });

  it('should not error on valid search query', async () => {
    req.query.q = 'Inception';

    const mockLimit = jest.fn().mockResolvedValue([]);
    Movie.find.mockReturnValue({ limit: mockLimit });

    await smartSearch(req, res, next);

    expect(Movie.find).toHaveBeenCalled();
    const filterCall = Movie.find.mock.calls[0][0];

    expect(filterCall.$or).toBeDefined();
    const titleRegex = filterCall.$or[0].title;
    expect(titleRegex.toString()).toBe('/Inception/i');
  });
});
