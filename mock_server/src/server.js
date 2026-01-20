require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const config = require('./config');
const authRoutes = require('./routes/authRoutes');
const taskRoutes = require('./routes/taskRoutes');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// ===================
// Middleware
// ===================
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS for Flutter app
app.use(express.json()); // Parse JSON bodies

// Request logging middleware
app.use((req, res, next) => {
 const timestamp = new Date().toISOString();
 console.log(`\n[${timestamp}] ${req.method} ${req.url}`);
 next();
});

// ===================
// Routes
// ===================
app.use('/auth', authRoutes);
app.use('/tasks', taskRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
 res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
 res.status(404).json({ error: 'Endpoint not found' });
});

// Global error handler
app.use(errorHandler);

// ===================
// Start Server
// ===================
app.listen(config.port, () => {
 console.log('╔════════════════════════════════════════════╗');
 console.log('║   🚀 Mock Auth Server Started!             ║');
 console.log('╠════════════════════════════════════════════╣');
 console.log(`║   Port: ${config.port}                              ║`);
 console.log(`║   Access Token Expiry: ${config.accessTokenExpiry.padEnd(16)}║`);
 console.log(`║   Refresh Token Expiry: ${config.refreshTokenExpiry.padEnd(15)}║`);
 console.log('╠════════════════════════════════════════════╣');
 console.log('║   Endpoints:                               ║');
 console.log('║   POST /auth/login         (Simple login)  ║');
 console.log('║   POST /auth/google        (Google login)  ║');
 console.log('║   POST /auth/refresh-token (Refresh)       ║');
 console.log('║   GET  /tasks              (Protected)     ║');
 console.log('║   POST /tasks              (Protected)     ║');
 console.log('║   PUT  /tasks/:id          (Protected)     ║');
 console.log('║   DELETE /tasks/:id        (Protected)     ║');
 console.log('╚════════════════════════════════════════════╝');
});
