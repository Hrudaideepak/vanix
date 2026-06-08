module.exports = {
  testEnvironment: 'node',
  setupFiles: ['./tests/testSetup.js'], globalSetup: './tests/setup-mongo.js', globalTeardown: './tests/teardown-mongo.js',
};
