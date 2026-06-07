const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs').promises;
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const Video = require('../models/video.model');

// S3 configuration
const s3 = new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint: process.env.S3_ENDPOINT || undefined,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'mock_access_key',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'mock_secret_key',
  },
  forcePathStyle: true, // Required for R2
});

const BUCKET_NAME = process.env.S3_BUCKET_NAME || 'vanix-videos';
const TEMP_PATH = process.env.TEMP_VIDEO_PATH || './temp/uploads';

// Quality profiles for adaptive streaming
const QUALITIES = [
  { name: '360p', height: 360, bitrate: '800k', maxrate: '856k', bufsize: '1200k' },
  { name: '720p', height: 720, bitrate: '2500k', maxrate: '2675k', bufsize: '3750k' },
  { name: '1080p', height: 1080, bitrate: '5000k', maxrate: '5350k', bufsize: '7500k' },
];

async function processVideo(videoId, inputPath, originalFilename) {
  const startTime = Date.now();
  const outputDir = path.join(TEMP_PATH, videoId);
  try {
    console.log(`🎬 Transcoding starting for video: ${videoId}`);
    await Video.findByIdAndUpdate(videoId, { status: 'processing' });

    // Create temporary directory for this video
    await fs.mkdir(outputDir, { recursive: true });

    // Get video metadata
    const metadata = await getVideoMetadata(inputPath);
    await Video.findByIdAndUpdate(videoId, {
      duration: Math.round(metadata.duration),
      resolution: `${metadata.width}x${metadata.height}`,
      bitrate: metadata.bitrate,
    });

    // Generate thumbnails
    console.log(`🖼️ Generating thumbnails for video: ${videoId}`);
    const thumbnails = await generateThumbnails(inputPath, outputDir, videoId);

    // Generate HLS streams for each quality
    console.log(`📹 Transcoding variants for video: ${videoId}`);
    const variantPlaylists = [];
    for (const quality of QUALITIES) {
      if (metadata.height >= quality.height || quality.name === '360p') {
        console.log(`   └─ Transcoding to ${quality.name}...`);
        await transcodeToHLS(inputPath, outputDir, videoId, quality);
        variantPlaylists.push({
          quality: quality.name,
          bitrate: quality.bitrate,
        });
      }
    }

    // Generate master playlist
    console.log(`📝 Generating master playlist for video: ${videoId}`);
    const masterPlaylist = generateMasterPlaylist(variantPlaylists);
    const masterPlaylistPath = path.join(outputDir, 'master.m3u8');
    await fs.writeFile(masterPlaylistPath, masterPlaylist);

    // Upload folder contents to S3
    console.log(`☁️ Uploading transcoded assets to S3/R2 for video: ${videoId}`);
    const uploadedUrls = await uploadFolderToS3(outputDir, videoId);

    // Find master playlist URL and thumbnail URLs
    const masterPlaylistUrl = uploadedUrls['master.m3u8'];
    const thumbnailUrls = Object.keys(uploadedUrls)
      .filter(fileName => fileName.startsWith('thumbnail-'))
      .map(fileName => uploadedUrls[fileName]);

    // Update video record
    await Video.findByIdAndUpdate(videoId, {
      hlsPlaylistUrl: masterPlaylistUrl,
      thumbnailUrls: thumbnailUrls,
      status: 'completed',
    });

    // Cleanup temporary files
    console.log(`🧹 Cleaning up temporary files for video: ${videoId}`);
    await fs.rm(outputDir, { recursive: true, force: true }).catch(() => {});
    await fs.unlink(inputPath).catch(() => {});

    console.log(`✅ Video ${videoId} transcoded successfully in ${Date.now() - startTime}ms`);
    return { success: true, playlistUrl: masterPlaylistUrl };
  } catch (error) {
    console.error(`❌ Transcoding failed for video ${videoId}:`, error);
    await Video.findByIdAndUpdate(videoId, {
      status: 'failed',
      transcodingError: error.message,
    });
    // Cleanup temporary files on error
    await fs.rm(outputDir, { recursive: true, force: true }).catch(() => {});
    await fs.unlink(inputPath).catch(() => {});
    throw error;
  }
}

async function getVideoMetadata(filePath) {
  return new Promise((resolve, reject) => {
    ffmpeg.ffprobe(filePath, (err, metadata) => {
      if (err) return reject(err);
      const videoStream = metadata.streams.find(s => s.codec_type === 'video');
      if (!videoStream) return reject(new Error('No video stream found'));
      resolve({
        duration: parseFloat(metadata.format.duration) || 0,
        width: videoStream.width || 0,
        height: videoStream.height || 0,
        bitrate: metadata.format.bit_rate || '',
      });
    });
  });
}

async function generateThumbnails(inputPath, outputDir, videoId) {
  return new Promise((resolve, reject) => {
    const filenames = [];
    ffmpeg(inputPath)
      .on('filenames', (fns) => {
        fns.forEach(f => filenames.push(path.join(outputDir, f)));
      })
      .on('end', () => {
        resolve(filenames);
      })
      .on('error', (err) => {
        reject(err);
      })
      .screenshots({
        count: 4,
        folder: outputDir,
        size: '320x180',
        filename: `thumbnail-${videoId}-%i.png`,
      });
  });
}

async function transcodeToHLS(inputPath, outputDir, videoId, quality) {
  const outputM3u8 = path.join(outputDir, `${quality.name}.m3u8`);
  return new Promise((resolve, reject) => {
    ffmpeg(inputPath)
      .output(outputM3u8)
      .videoCodec('libx264')
      .audioCodec('aac')
      .size(`?x${quality.height}`)
      .videoBitrate(quality.bitrate)
      .addOption('-maxrate', quality.maxrate)
      .addOption('-bufsize', quality.bufsize)
      .addOption('-preset', 'medium')
      .addOption('-profile:v', 'main')
      .addOption('-g', '48')
      .addOption('-keyint_min', '48')
      .addOption('-sc_threshold', '0')
      .addOption('-b:a', '128k')
      .addOption('-ac', '2')
      .addOption('-start_number', '0')
      .addOption('-hls_time', '6')
      .addOption('-hls_list_size', '0')
      .addOption('-f', 'hls')
      .addOption('-hls_segment_filename', path.join(outputDir, `${quality.name}-%03d.ts`))
      .on('end', () => resolve(outputM3u8))
      .on('error', (err) => reject(err))
      .run();
  });
}

function generateMasterPlaylist(variants) {
  let playlist = '#EXTM3U\n';
  playlist += '#EXT-X-VERSION:3\n';
  for (const variant of variants) {
    const resolution = variant.quality === '360p' ? '640x360' : variant.quality === '720p' ? '1280x720' : '1920x1080';
    playlist += `#EXT-X-STREAM-INF:BANDWIDTH=${parseInt(variant.bitrate) * 1000},RESOLUTION=${resolution}\n`;
    playlist += `${variant.quality}.m3u8\n`;
  }
  return playlist;
}

async function uploadFolderToS3(localDir, s3Prefix) {
  const urls = {};
  const entries = await fs.readdir(localDir, { withFileTypes: true });
  for (const entry of entries) {
    if (entry.isFile()) {
      const fullPath = path.join(localDir, entry.name);
      const relativePath = entry.name;
      const s3Key = `${s3Prefix}/${relativePath}`;
      const fileBuffer = await fs.readFile(fullPath);
      const command = new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: s3Key,
        Body: fileBuffer,
        ContentType: getContentType(entry.name),
      });
      await s3.send(command);

      const fileUrl = process.env.CLOUDFRONT_DOMAIN
        ? `${process.env.CLOUDFRONT_DOMAIN}/${s3Key}`
        : `https://${BUCKET_NAME}.s3.amazonaws.com/${s3Key}`;

      urls[relativePath] = fileUrl;
    }
  }
  return urls;
}

function getContentType(filename) {
  if (filename.endsWith('.m3u8')) return 'application/vnd.apple.mpegurl';
  if (filename.endsWith('.ts')) return 'video/MP2T';
  if (filename.endsWith('.png')) return 'image/png';
  return 'application/octet-stream';
}

module.exports = { processVideo };
