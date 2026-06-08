const { Queue, Worker } = require('bullmq');
const Redis = require('ioredis');

let connection = null;
let transcodingQueue = null;
let transcodingWorker = null;

if (process.env.NODE_ENV !== 'test' && process.env.USE_MOCK_REDIS !== 'true') {
  connection = new Redis({
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT) || 6379,
    maxRetriesPerRequest: null,
  });

  // Queue for video transcoding jobs
  transcodingQueue = new Queue('video-transcoding', { connection });

  // Worker to process jobs
  transcodingWorker = new Worker('video-transcoding', async (job) => {
    const { videoId, filePath, originalFilename } = job.data;
    const transcoder = require('../services/transcoder');
    return await transcoder.processVideo(videoId, filePath, originalFilename);
  }, { connection });

  transcodingWorker.on('completed', (job) => {
    console.log(`Job ${job.id} completed for video ${job.data.videoId}`);
  });

  transcodingWorker.on('failed', (job, err) => {
    console.error(`Job ${job.id} failed:`, err);
  });
} else {
  // Mock implementations for test environments to avoid leaking Redis connection handles
  transcodingQueue = {
    add: async () => ({ id: 'mock-job-id' }),
    close: async () => {},
  };
  transcodingWorker = {
    close: async () => {},
  };
}

module.exports = { transcodingQueue, transcodingWorker, connection };
