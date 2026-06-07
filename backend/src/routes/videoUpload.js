const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const Video = require('../models/video.model');
const { transcodingQueue } = require('../queue/queue');
const { protect, authorize } = require('../middlewares/auth.middleware');

const router = express.Router();

// Configure multer for temporary storage
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const tempDir = process.env.TEMP_VIDEO_PATH || './temp/uploads';
    await fs.mkdir(tempDir, { recursive: true });
    cb(null, tempDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 * 1024 }, // 10GB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/x-matroska'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only MP4, MOV, AVI, and MKV are allowed.'));
    }
  },
});

// Upload endpoint
router.post('/upload', protect, authorize('admin', 'super-admin'), upload.single('video'), async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No video file provided' });
    }

    // Create video record in database
    const video = new Video({
      title: req.body.title || path.basename(req.file.originalname, path.extname(req.file.originalname)),
      description: req.body.description || '',
      genre: req.body.genre || 'Uncategorized',
      originalUrl: req.file.path,
      status: 'pending',
    });
    await video.save();

    // Queue transcoding job
    await transcodingQueue.add('transcode', {
      videoId: video._id,
      filePath: req.file.path,
      originalFilename: req.file.originalname,
    });

    res.status(201).json({
      success: true,
      videoId: video._id,
      message: 'Video uploaded and queued for transcoding',
      status: 'pending',
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Check transcoding status
router.get('/status/:videoId', protect, async (req, res) => {
  try {
    const video = await Video.findById(req.params.videoId);
    if (!video) {
      return res.status(404).json({ success: false, error: 'Video not found' });
    }
    res.json({
      success: true,
      status: video.status,
      hlsPlaylistUrl: video.hlsPlaylistUrl,
      thumbnailUrls: video.thumbnailUrls,
      duration: video.duration,
      resolution: video.resolution,
      error: video.transcodingError,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
