const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const connectDB = require('./config/db');
const env = require('./config/env');
const errorHandler = require('./middlewares/error');

// Initialize express app
const app = express();

// Connect to Database
if (process.env.NODE_ENV !== 'test') {
  connectDB();
}

// Security Middlewares
app.use(helmet());
app.use(cors({
  origin: '*', // For development, allow all origins
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-profile-id'],
}));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
if (env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again after 15 minutes',
  },
});
app.use('/api', limiter);

// Welcome Route
app.get('/', (req, res) => {
  res.json({
    status: 'online',
    name: 'VANIX OTT Backend API',
    version: '1.0.0',
    tagline: 'Unlimited Entertainment. One Universe.',
  });
});

// Import Routes
const authRoutes = require('./routes/auth.routes');
const contentRoutes = require('./routes/content.routes');
const watchlistRoutes = require('./routes/watchlist.routes');
const historyRoutes = require('./routes/history.routes');
const uploadRoutes = require('./routes/upload.routes');
const subscriptionRoutes = require('./routes/subscription.routes');
const profileRoutes = require('./routes/profile.routes');
const deviceRoutes = require('./routes/device.routes');
const searchRoutes = require('./routes/search.routes');
const recommendationRoutes = require('./routes/recommendation.routes');
const analyticsRoutes = require('./routes/analytics.routes');

// Mount Routes
app.use('/api', authRoutes);
app.use('/api', contentRoutes);
app.use('/api', watchlistRoutes);
app.use('/api', historyRoutes);
app.use('/api', uploadRoutes);
app.use('/api', subscriptionRoutes);
app.use('/api', profileRoutes);
app.use('/api', deviceRoutes);
app.use('/api', searchRoutes);
app.use('/api', recommendationRoutes);
app.use('/api', analyticsRoutes);

// Catch 404 Route Not Found
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `API Route Not Found: [${req.method}] ${req.originalUrl}`,
  });
});

// Global Error Handler
app.use(errorHandler);

// Start server
if (process.env.NODE_ENV !== 'test') {
  app.listen(env.PORT, () => {
    console.log(`🚀 VANIX Server running in ${env.NODE_ENV} mode on port ${env.PORT}`);
  });
}

module.exports = app;
