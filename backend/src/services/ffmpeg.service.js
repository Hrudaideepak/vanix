const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const isFFmpegAvailable = () => {
  return new Promise((resolve) => {
    exec('ffmpeg -version', (error) => {
      resolve(!error);
    });
  });
};

exports.processVideoPipeline = async (inputFilePath, outputDirName) => {
  const outputDir = path.join(__dirname, '../../public/processed', outputDirName);
  
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const ffmpegInstalled = await isFFmpegAvailable();
  
  if (!ffmpegInstalled) {
    console.warn('⚠️ FFmpeg is not installed on this system. Falling back to Mock Video processing pipeline...');
    
    const hlsUrl = `/processed/${outputDirName}/master.m3u8`;
    const trailerUrl = `/processed/${outputDirName}/trailer.mp4`;
    const thumbnailUrl = `/processed/${outputDirName}/thumbnail.jpg`;
    const previewImages = [
      `/processed/${outputDirName}/preview_1.jpg`,
      `/processed/${outputDirName}/preview_2.jpg`,
      `/processed/${outputDirName}/preview_3.jpg`,
    ];
    
    const resolutions = {
      '240p': `/processed/${outputDirName}/240p.m3u8`,
      '360p': `/processed/${outputDirName}/360p.m3u8`,
      '480p': `/processed/${outputDirName}/480p.m3u8`,
      '720p': `/processed/${outputDirName}/720p.m3u8`,
      '1080p': `/processed/${outputDirName}/1080p.m3u8`,
    };

    fs.writeFileSync(path.join(outputDir, 'master.m3u8'), '#EXTM3U\n#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=426x240\n240p.m3u8\n#EXT-X-STREAM-INF:BANDWIDTH=1400000,RESOLUTION=854x480\n480p.m3u8\n#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720\n720p.m3u8\n#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080\n1080p.m3u8\n');
    fs.writeFileSync(path.join(outputDir, '240p.m3u8'), '#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:10\n#EXTINF:10.0,\nsegment_0.ts\n#EXT-X-ENDLIST');
    fs.writeFileSync(path.join(outputDir, '360p.m3u8'), '#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:10\n#EXTINF:10.0,\nsegment_0.ts\n#EXT-X-ENDLIST');
    fs.writeFileSync(path.join(outputDir, '480p.m3u8'), '#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:10\n#EXTINF:10.0,\nsegment_0.ts\n#EXT-X-ENDLIST');
    fs.writeFileSync(path.join(outputDir, '720p.m3u8'), '#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:10\n#EXTINF:10.0,\nsegment_0.ts\n#EXT-X-ENDLIST');
    fs.writeFileSync(path.join(outputDir, '1080p.m3u8'), '#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:10\n#EXTINF:10.0,\nsegment_0.ts\n#EXT-X-ENDLIST');

    return {
      hlsUrl,
      resolutions,
      trailerUrl,
      thumbnailUrl,
      previewImages,
    };
  }

  console.log(`🚀 Starting FFmpeg transcoding for ${inputFilePath}...`);
  try {
    const resolutions = {
      '240p': { width: 426, height: 240, bitrate: '400k', bufsize: '800k' },
      '360p': { width: 640, height: 360, bitrate: '800k', bufsize: '1600k' },
      '480p': { width: 854, height: 480, bitrate: '1400k', bufsize: '2800k' },
      '720p': { width: 1280, height: 720, bitrate: '2800k', bufsize: '5600k' },
      '1080p': { width: 1920, height: 1080, bitrate: '5000k', bufsize: '10000k' },
    };

    await new Promise((resolve, reject) => {
      exec(`ffmpeg -y -i "${inputFilePath}" -ss 00:00:05 -vframes 1 "${path.join(outputDir, 'thumbnail.jpg')}"`, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    for (let i = 1; i <= 3; i++) {
      const sec = i * 15;
      await new Promise((resolve) => {
        exec(`ffmpeg -y -i "${inputFilePath}" -ss ${sec} -vframes 1 "${path.join(outputDir, `preview_${i}.jpg`)}"`, () => {
          resolve();
        });
      });
    }

    await new Promise((resolve, reject) => {
      exec(`ffmpeg -y -i "${inputFilePath}" -ss 0 -t 10 -c copy "${path.join(outputDir, 'trailer.mp4')}"`, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    const resPaths = {};
    for (const [resName, config] of Object.entries(resolutions)) {
      const resFile = `${resName}.m3u8`;
      const cmd = `ffmpeg -y -i "${inputFilePath}" -vf "scale=${config.width}:${config.height}" -c:v libx264 -b:v ${config.bitrate} -maxrate ${config.bitrate} -bufsize ${config.bufsize} -c:a aac -b:a 128k -hls_time 10 -hls_playlist_type vod -hls_segment_filename "${path.join(outputDir, `${resName}_%03d.ts`)}" "${path.join(outputDir, resFile)}"`;
      
      await new Promise((resolve, reject) => {
        exec(cmd, (err) => {
          if (err) reject(err);
          else resolve();
        });
      });
      resPaths[resName] = `/processed/${outputDirName}/${resFile}`;
    }

    let masterContent = '#EXTM3U\n';
    masterContent += '#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=426x240\n240p.m3u8\n';
    masterContent += '#EXT-X-STREAM-INF:BANDWIDTH=1200000,RESOLUTION=640x360\n360p.m3u8\n';
    masterContent += '#EXT-X-STREAM-INF:BANDWIDTH=1800000,RESOLUTION=854x480\n480p.m3u8\n';
    masterContent += '#EXT-X-STREAM-INF:BANDWIDTH=3000000,RESOLUTION=1280x720\n720p.m3u8\n';
    masterContent += '#EXT-X-STREAM-INF:BANDWIDTH=5500000,RESOLUTION=1920x1080\n1080p.m3u8\n';
    fs.writeFileSync(path.join(outputDir, 'master.m3u8'), masterContent);

    return {
      hlsUrl: `/processed/${outputDirName}/master.m3u8`,
      resolutions: resPaths,
      trailerUrl: `/processed/${outputDirName}/trailer.mp4`,
      thumbnailUrl: `/processed/${outputDirName}/thumbnail.jpg`,
      previewImages: [
        `/processed/${outputDirName}/preview_1.jpg`,
        `/processed/${outputDirName}/preview_2.jpg`,
        `/processed/${outputDirName}/preview_3.jpg`,
      ],
    };
  } catch (error) {
    console.error('🔴 FFmpeg pipeline failure:', error);
    throw error;
  }
};
