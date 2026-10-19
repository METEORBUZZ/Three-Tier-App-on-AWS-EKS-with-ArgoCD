const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const { metricsMiddleware } = require('./middleware/metricsMiddleware');
const { notFound, errorHandler } = require('./middleware/errorHandler');

const healthRoutes = require('./routes/healthRoutes');
const metricsRoutes = require('./routes/metricsRoutes');
const taskRoutes = require('./routes/taskRoutes');

const app = express();

// CORS configuration
const corsOrigin = process.env.CORS_ORIGIN || '*';
app.use(cors({
  origin: corsOrigin === '*' ? '*' : corsOrigin.split(','),
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parsing
app.use(express.json());

// Prometheus Metrics Middleware
app.use(metricsMiddleware);

// Route mounts
app.use('/health', healthRoutes);
app.use('/metrics', metricsRoutes);
app.use('/api/tasks', taskRoutes);

// Error Handling Middlewares
app.use(notFound);
app.use(errorHandler);

module.exports = app;
