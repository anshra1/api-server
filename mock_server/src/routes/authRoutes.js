const express = require('express');
const rateLimit = require('express-rate-limit');
const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/authMiddleware');
const {
 validateRegister,
 validateLogin,
 validatePasswordChange,
 handleValidationErrors,
} = require('../validators');

const router = express.Router();

// Rate limiting for auth endpoints (prevents brute-force attacks)
const authLimiter = rateLimit({
 windowMs: 15 * 60 * 1000, // 15 minutes
 max: 10, // 10 attempts per window
 message: {
  error: {
   code: 'RATE_LIMITED',
   message: 'Too many attempts, please try again in 15 minutes',
  },
 },
 standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
 legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// POST /auth/register - Register new user
router.post(
 '/register',
 authLimiter,
 validateRegister,
 handleValidationErrors,
 authController.register
);

// POST /auth/login - Login with email and password
router.post(
 '/login',
 authLimiter,
 validateLogin,
 handleValidationErrors,
 authController.login
);

// POST /auth/google - Login with Google ID Token
router.post('/google', authController.googleLogin);

// POST /auth/refresh-token - Get new access token
router.post('/refresh-token', authController.refreshAccessToken);

// POST /auth/logout - Invalidate refresh token
router.post('/logout', authController.logout);

// PUT /auth/change-password - Change password (requires authentication)
router.put(
 '/change-password',
 authMiddleware,
 validatePasswordChange,
 handleValidationErrors,
 authController.changePassword
);

module.exports = router;
