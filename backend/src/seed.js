const mongoose = require('mongoose');
const env = require('./config/env');
const User = require('./models/user.model');
const Movie = require('./models/movie.model');
const Profile = require('./models/profile.model');
const Watchlist = require('./models/watchlist.model');
const History = require('./models/history.model');

const movies = [
  {
    title: 'Nebula Genesis',
    description: 'In the year 2350, a deep-space research pilot discovers a cosmic energy anomaly that alters the fabric of time and human consciousness.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=500&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?w=1000&q=80',
    videoUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    hlsUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    resolutions: {
      '240p': 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/tears-of-steel-audio_eng=128000-video_eng=150000.m3u8',
      '360p': 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/tears-of-steel-audio_eng=128000-video_eng=400000.m3u8',
      '480p': 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/tears-of-steel-audio_eng=128000-video_eng=750000.m3u8',
      '720p': 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/tears-of-steel-audio_eng=128000-video_eng=2200000.m3u8',
      '1080p': 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/tears-of-steel-audio_eng=128000-video_eng=3500000.m3u8'
    },
    trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    previewImages: [
      'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500',
      'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500'
    ],
    subtitles: [
      { language: 'English', url: 'https://raw.githubusercontent.com/run-dmc/subtitles/master/sample.vtt', format: 'vtt' },
      { language: 'Spanish', url: 'https://raw.githubusercontent.com/run-dmc/subtitles/master/sample.vtt', format: 'vtt' }
    ],
    audioTracks: [
      { language: 'English', url: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8' },
      { language: 'Hindi', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4' }
    ],
    type: 'movie',
    rating: 8.9,
    releaseYear: 2024,
    duration: '2h 15m',
    genres: ['Sci-Fi', 'Thriller', 'Space Opera'],
    isPremium: true,
    isFeatured: true,
    cast: ['Alexander Vance', 'Elena Rostova', 'Kaelen Thorne'],
    crew: ['Marcus Sterling (Director)', 'Sarah Lin (Producer)'],
  },
  {
    title: 'Shadow Sector',
    description: 'An elite cyberpunk operative is blackmailed into executing the heist of the century inside a heavily fortified synthetic megastructure.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=500&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1000&q=80',
    videoUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
    hlsUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
    resolutions: {
      '480p': 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
      '720p': 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8'
    },
    trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    previewImages: [
      'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500'
    ],
    subtitles: [
      { language: 'English', url: 'https://raw.githubusercontent.com/run-dmc/subtitles/master/sample.vtt', format: 'vtt' }
    ],
    audioTracks: [
      { language: 'English', url: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8' }
    ],
    type: 'movie',
    rating: 8.4,
    releaseYear: 2024,
    duration: '1h 58m',
    genres: ['Cyberpunk', 'Action', 'Sci-Fi'],
    isPremium: true,
    isFeatured: true,
    cast: ['Damian Vance', 'Chloe Kross'],
    crew: ['Kenji Sato (Director)'],
  },
  {
    title: 'Ragnarok Rising',
    description: 'Nordic gods fight alongside mortal heroes to protect the realm of Midgard from the fiery destruction of Surtur and his dark legion.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1000&q=80',
    videoUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    hlsUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    resolutions: {
      '720p': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'
    },
    trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    type: 'movie',
    rating: 9.1,
    releaseYear: 2024,
    duration: '2h 45m',
    genres: ['Fantasy', 'Action', 'Epic'],
    isPremium: true,
    cast: ['Torstein Valur', 'Astrid Harald'],
    crew: ['Gunnar Ericson (Director)'],
  },
  {
    title: 'Midnight Heist',
    description: 'A retired safecracker is drawn back for one final job by a secret organization, only to realize he is the target of a setup.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1000&q=80',
    videoUrl: 'https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8',
    hlsUrl: 'https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8',
    type: 'movie',
    rating: 7.8,
    releaseYear: 2023,
    duration: '1h 42m',
    genres: ['Action', 'Thriller'],
    isPremium: false,
    cast: ['Julian Cole', 'Rebecca Cruz'],
    crew: ['Alan Smithee (Director)'],
  },
  {
    title: 'Chronicles of Chronos',
    description: 'Time travellers from distinct eras assemble in ancient Rome to defend human history from a temporal saboteur group.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1000&q=80',
    videoUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    hlsUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    type: 'series',
    rating: 8.7,
    releaseYear: 2024,
    duration: '1 Season',
    genres: ['Sci-Fi', 'Mystery', 'Drama'],
    isPremium: false,
    cast: ['Leo Miller', 'Grace Hopper'],
    crew: ['Sophia Coppola (Director)'],
  },
  {
    title: 'Ocean Deep',
    description: 'An exploration team investigating the Mariana Trench encounters a prehistoric aquatic leviathan that rises to reclaim the sea.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=500&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=1000&q=80',
    videoUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    hlsUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    type: 'movie',
    rating: 8.2,
    releaseYear: 2023,
    duration: '2h 05m',
    genres: ['Kids', 'Animation', 'Family', 'Fantasy'],
    isPremium: true,
    cast: ['Cyrus Webb', 'Lana Vance'],
    crew: ['James Cameron (Director)'],
  }
];

const seedDB = async () => {
  try {
    // Connect to Mongo
    await mongoose.connect(env.MONGO_URI);
    console.log('📡 Connected to MongoDB for seeding...');

    // Clear DB
    await User.deleteMany();
    await Movie.deleteMany();
    await Profile.deleteMany();
    await Watchlist.deleteMany();
    await History.deleteMany();
    console.log('🗑️ Existing tables cleared.');

    // Seed Movies
    const seededMovies = await Movie.insertMany(movies);
    console.log(`🎬 Seeded ${seededMovies.length} movies/shows.`);

    // Seed Admin Account
    const adminUser = await User.create({
      email: 'admin@vanix.com',
      password: 'adminpassword123',
      role: 'admin',
      subscriptionPlan: 'premium',
    });

    const adminProfile = await Profile.create({
      user: adminUser._id,
      name: 'Admin HQ',
      avatarUrl: `https://api.dicebear.com/7.x/bottts/png?seed=${adminUser._id}`,
      isKids: false,
    });

    adminUser.profiles.push(adminProfile._id);
    await adminUser.save();
    console.log('👥 Seeded Admin Account: admin@vanix.com / adminpassword123');

    // Seed Standard User Account
    const normalUser = await User.create({
      email: 'user@vanix.com',
      password: 'userpassword123',
      role: 'user',
      subscriptionPlan: 'premium',
    });

    const normalProfile = await Profile.create({
      user: normalUser._id,
      name: 'Default User',
      avatarUrl: `https://api.dicebear.com/7.x/bottts/png?seed=${normalUser._id}`,
      isKids: false,
    });

    normalUser.profiles.push(normalProfile._id);
    await normalUser.save();
    console.log('👥 Seeded User Account: user@vanix.com / userpassword123');

    console.log('🎉 Database seeding complete!');
    process.exit(0);
  } catch (error) {
    console.error('🔴 Seeding Error:', error);
    process.exit(1);
  }
};

seedDB();
