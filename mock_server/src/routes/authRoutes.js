const express = require('express');
const authController = require('../controllers/authController');

const router = express.Router();

// POST /auth/google - Login with Google ID Token
router.post('/google', authController.googleLogin);

// POST /auth/login - Simple login for testing
router.post('/login', authController.simpleLogin);

// POST /auth/refresh-token - Get new access token
router.post('/refresh-token', authController.refreshAccessToken);

// POST /auth/logout - Invalidate refresh token
router.post('/logout', authController.logout);

module.exports = router;
