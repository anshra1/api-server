const express = require('express');
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');
const { validateProfileUpdate, handleValidationErrors } = require('../validators');

const router = express.Router();

// All user routes require authentication
router.use(authMiddleware);

// GET /users/me - Get current user's profile
router.get('/me', userController.getProfile);

// PUT /users/me - Update current user's profile
router.put('/me', validateProfileUpdate, handleValidationErrors, userController.updateProfile);

// DELETE /users/me - Delete current user's account
router.delete('/me', userController.deleteAccount);

// GET /users/me/stats - Get user's account statistics
router.get('/me/stats', userController.getAccountStats);

module.exports = router;
