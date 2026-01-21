require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');

const config = require('./config');
const authRoutes = require('./routes/authRoutes');
const taskRoutes = require('./routes/taskRoutes');
const userRoutes = require('./routes/userRoutes');
const errorHandler = require('./middleware/errorHandler');

// Initialize database (this runs schema.sql)
require('./db');

const app = express();

// ===================
// Middleware
// ===================
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS for Flutter app
app.use(compression()); // Gzip compression
app.use(express.json()); // Parse JSON bodies

// Request logging with morgan
app.use(morgan(':method :url :status :res[content-length] - :response-time ms'));

// Additional detailed logging
app.use((req, res, next) => {
 const timestamp = new Date().toISOString();
 console.log(`\n[${timestamp}] ${req.method} ${req.url}`);
 next();
});

// ===================
// API v1 Routes (new)
// ===================
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/tasks', taskRoutes);
app.use('/api/v1/users', userRoutes);

// ===================
// Legacy Routes (for backward compatibility)
// ===================
app.use('/auth', authRoutes);
app.use('/tasks', taskRoutes);
app.use('/users', userRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
 res.json({
  status: 'ok',
  timestamp: new Date().toISOString(),
  version: '1.0.0',
  database: 'sqlite',
 });
});

// API info endpoint
app.get('/', (req, res) => {
 res.json({
  name: 'Task Manager API',
  version: '1.0.0',
  documentation: {
   auth: {
    'POST /auth/register': 'Register new user',
    'POST /auth/login': 'Login with email/password',
    'POST /auth/google': 'Login with Google',
    'POST /auth/refresh-token': 'Refresh access token',
    'POST /auth/logout': 'Logout',
    'PUT /auth/change-password': 'Change password (auth required)',
   },
   users: {
    'GET /users/me': 'Get profile (auth required)',
    'PUT /users/me': 'Update profile (auth required)',
    'DELETE /users/me': 'Delete account (auth required)',
    'GET /users/me/stats': 'Get account stats (auth required)',
   },
   tasks: {
    'GET /tasks': 'Get tasks with pagination/search/filters (auth required)',
    'GET /tasks/:id': 'Get single task (auth required)',
    'GET /tasks/stats': 'Get task statistics (auth required)',
    'GET /tasks/categories': 'Get all categories (auth required)',
    'POST /tasks': 'Create task (auth required)',
    'PUT /tasks/:id': 'Update task (auth required)',
    'DELETE /tasks/:id': 'Delete task (auth required)',
    'POST /tasks/batch/complete': 'Batch complete tasks (auth required)',
    'DELETE /tasks/batch': 'Batch delete tasks (auth required)',
   },
  },
  queryParameters: {
   'GET /tasks': {
    page: 'Page number (default: 1)',
    limit: 'Items per page (default: 20, max: 100)',
    sort: 'Sort by: created_at, due_date, title, priority',
    order: 'Sort order: asc, desc',
    search: 'Search in title and subtitle',
    isCompleted: 'Filter: true or false',
    priority: 'Filter: low, medium, high',
    category: 'Filter by category',
   },
  },
 });
});

// 404 handler
app.use((req, res) => {
 res.status(404).json({
  error: {
   code: 'NOT_FOUND',
   message: `Endpoint ${req.method} ${req.url} not found`,
  },
 });
});

// Global error handler
app.use(errorHandler);

// ===================
// Start Server
// ===================
app.listen(config.port, () => {
 console.log('');
 console.log('╔════════════════════════════════════════════════════════════╗');
 console.log('║   🚀 Production-Like Task Manager API Started!             ║');
 console.log('╠════════════════════════════════════════════════════════════╣');
 console.log(`║   Port: ${String(config.port).padEnd(49)}║`);
 console.log(`║   Database: SQLite                                         ║`);
 console.log(`║   Access Token Expiry: ${config.accessTokenExpiry.padEnd(35)}║`);
 console.log(`║   Refresh Token Expiry: ${config.refreshTokenExpiry.padEnd(34)}║`);
 console.log('╠════════════════════════════════════════════════════════════╣');
 console.log('║   Auth Endpoints:                                          ║');
 console.log('║   POST /auth/register          (New user registration)     ║');
 console.log('║   POST /auth/login             (Email/password login)      ║');
 console.log('║   POST /auth/google            (Google OAuth login)        ║');
 console.log('║   POST /auth/refresh-token     (Refresh access token)      ║');
 console.log('║   PUT  /auth/change-password   (Change password)           ║');
 console.log('╠════════════════════════════════════════════════════════════╣');
 console.log('║   User Endpoints:                                          ║');
 console.log('║   GET  /users/me               (Get profile)               ║');
 console.log('║   PUT  /users/me               (Update profile)            ║');
 console.log('║   DELETE /users/me             (Delete account)            ║');
 console.log('╠════════════════════════════════════════════════════════════╣');
 console.log('║   Task Endpoints:                                          ║');
 console.log('║   GET  /tasks                  (List with pagination)      ║');
 console.log('║   GET  /tasks/stats            (Task statistics)           ║');
 console.log('║   GET  /tasks/categories       (Get categories)            ║');
 console.log('║   POST /tasks                  (Create task)               ║');
 console.log('║   PUT  /tasks/:id              (Update task)               ║');
 console.log('║   DELETE /tasks/:id            (Soft delete task)          ║');
 console.log('║   POST /tasks/batch/complete   (Batch complete)            ║');
 console.log('║   DELETE /tasks/batch          (Batch delete)              ║');
 console.log('╠════════════════════════════════════════════════════════════╣');
 console.log('║   Features:                                                ║');
 console.log('║   ✅ Password hashing (bcrypt)                             ║');
 console.log('║   ✅ Rate limiting on auth endpoints                       ║');
 console.log('║   ✅ Input validation                                      ║');
 console.log('║   ✅ SQLite database                                       ║');
 console.log('║   ✅ Pagination, search, filters                           ║');
 console.log('║   ✅ Soft delete                                           ║');
 console.log('║   ✅ Response compression                                  ║');
 console.log('║   ✅ API versioning (/api/v1/)                             ║');
 console.log('╚════════════════════════════════════════════════════════════╝');
 console.log('');
});
