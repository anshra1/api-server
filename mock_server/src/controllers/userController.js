const userRepository = require('../repositories/userRepository');
const taskRepository = require('../repositories/taskRepository');
const tokenRepository = require('../repositories/tokenRepository');
const bcrypt = require('bcrypt');

/**
 * GET /users/me
 * Get the current user's profile
 */
const getProfile = (req, res) => {
 const userId = req.user.userId;

 const user = userRepository.findById(userId);
 if (!user) {
  return res.status(404).json({
   error: {
    code: 'USER_NOT_FOUND',
    message: 'User not found',
   },
  });
 }

 // Don't return password
 const { password, ...profile } = user;

 // Transform field names
 const response = {
  id: profile.id,
  email: profile.email,
  name: profile.name,
  picture: profile.picture,
  googleId: profile.google_id,
  createdAt: profile.created_at,
  updatedAt: profile.updated_at,
 };

 console.log(`👤 Profile fetched for: ${user.email}`);

 res.json(response);
};

/**
 * PUT /users/me
 * Update the current user's profile
 */
const updateProfile = (req, res) => {
 const userId = req.user.userId;
 const { name, picture } = req.body;

 const user = userRepository.findById(userId);
 if (!user) {
  return res.status(404).json({
   error: {
    code: 'USER_NOT_FOUND',
    message: 'User not found',
   },
  });
 }

 const updates = {};
 if (name !== undefined) updates.name = name;
 if (picture !== undefined) updates.picture = picture;

 const updatedUser = userRepository.update(userId, updates);

 // Don't return password
 const { password, ...profile } = updatedUser;

 const response = {
  id: profile.id,
  email: profile.email,
  name: profile.name,
  picture: profile.picture,
  googleId: profile.google_id,
  createdAt: profile.created_at,
  updatedAt: profile.updated_at,
 };

 console.log(`✏️  Profile updated for: ${updatedUser.email}`);

 res.json(response);
};

/**
 * DELETE /users/me
 * Delete the current user's account
 */
const deleteAccount = async (req, res) => {
 const userId = req.user.userId;
 const { password } = req.body;

 const user = userRepository.findById(userId);
 if (!user) {
  return res.status(404).json({
   error: {
    code: 'USER_NOT_FOUND',
    message: 'User not found',
   },
  });
 }

 // If user has a password, verify it
 if (user.password) {
  if (!password) {
   return res.status(400).json({
    error: {
     code: 'PASSWORD_REQUIRED',
     message: 'Password is required to delete your account',
    },
   });
  }

  const validPassword = await bcrypt.compare(password, user.password);
  if (!validPassword) {
   return res.status(401).json({
    error: {
     code: 'INVALID_PASSWORD',
     message: 'Invalid password',
    },
   });
  }
 }

 // Delete user (cascade will delete tasks and tokens due to foreign keys)
 const deleted = userRepository.delete(userId);

 if (!deleted) {
  return res.status(500).json({
   error: {
    code: 'DELETE_FAILED',
    message: 'Failed to delete account',
   },
  });
 }

 console.log(`🗑️  Account deleted for: ${user.email}`);

 res.json({ message: 'Account deleted successfully' });
};

/**
 * GET /users/me/stats
 * Get user's account statistics
 */
const getAccountStats = (req, res) => {
 const userId = req.user.userId;

 const user = userRepository.findById(userId);
 if (!user) {
  return res.status(404).json({
   error: {
    code: 'USER_NOT_FOUND',
    message: 'User not found',
   },
  });
 }

 const taskStats = taskRepository.getStats(userId);

 const stats = {
  user: {
   createdAt: user.created_at,
   hasPassword: !!user.password,
   hasGoogleLinked: !!user.google_id,
  },
  tasks: taskStats,
 };

 res.json(stats);
};

module.exports = {
 getProfile,
 updateProfile,
 deleteAccount,
 getAccountStats,
};
