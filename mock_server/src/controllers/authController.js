const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { OAuth2Client } = require('google-auth-library');
const config = require('../config');
const db = require('../models/database');

const googleClient = new OAuth2Client(config.googleClientId);

/**
 * Generate JWT Tokens
 */
const generateAccessToken = (user) => {
 return jwt.sign(
  { userId: user.id, email: user.email },
  config.accessTokenSecret,
  { expiresIn: config.accessTokenExpiry }
 );
};

const generateRefreshToken = (user) => {
 return jwt.sign(
  { userId: user.id, email: user.email },
  config.refreshTokenSecret,
  { expiresIn: config.refreshTokenExpiry }
 );
};

/**
 * POST /auth/google
 * Accepts a Google ID Token, verifies it, creates/finds user, returns tokens.
 */
const googleLogin = async (req, res) => {
 const { idToken } = req.body;

 if (!idToken) {
  return res.status(400).json({ error: 'idToken is required' });
 }

 try {
  // Verify Google ID Token
  console.log('🔍 Verifying Google ID Token...');

  let payload;

  // If GOOGLE_CLIENT_ID is not set, we'll skip verification for testing
  if (!config.googleClientId || config.googleClientId.includes('YOUR_GOOGLE')) {
   console.log('⚠️  GOOGLE_CLIENT_ID not configured. Skipping verification (DEV MODE).');
   // Decode without verification for development
   const base64Payload = idToken.split('.')[1];
   if (base64Payload) {
    payload = JSON.parse(Buffer.from(base64Payload, 'base64').toString());
   } else {
    // Mock payload for testing without real Google Token
    payload = {
     sub: 'test-user-' + Date.now(),
     email: 'testuser@example.com',
     name: 'Test User',
     picture: 'https://via.placeholder.com/150',
    };
   }
  } else {
   // Real verification
   const ticket = await googleClient.verifyIdToken({
    idToken: idToken,
    audience: config.googleClientId,
   });
   payload = ticket.getPayload();
  }

  console.log('✅ Google Token Payload:', payload.email);

  // Find or create user
  let user = db.findUserByEmail(payload.email);

  if (!user) {
   console.log('👤 Creating new user...');
   user = db.createUser({
    id: uuidv4(),
    email: payload.email,
    name: payload.name || 'Unknown',
    picture: payload.picture || null,
    googleId: payload.sub,
    createdAt: new Date().toISOString(),
   });
  } else {
   console.log('👤 Existing user found:', user.email);
  }

  // Generate tokens
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  // Store refresh token
  db.storeRefreshToken(user.id, refreshToken);

  console.log('🎫 Tokens generated successfully');

  res.json({
   accessToken,
   refreshToken,
   user: {
    id: user.id,
    email: user.email,
    name: user.name,
    picture: user.picture,
   },
  });
 } catch (error) {
  console.error('❌ Google Login Error:', error.message);
  res.status(401).json({ error: 'Invalid Google ID Token' });
 }
};

/**
 * POST /auth/login
 * Simple username/password login for testing (bypasses Google).
 */
const simpleLogin = async (req, res) => {
 const { username, password } = req.body;

 if (!username) {
  return res.status(400).json({ error: 'username is required' });
 }

 console.log(`📧 Simple login for: ${username}`);

 // Find or create user (password is ignored - this is for testing)
 let user = db.findUserByEmail(username);

 if (!user) {
  user = db.createUser({
   id: uuidv4(),
   email: username,
   name: username.split('@')[0],
   picture: null,
   googleId: null,
   createdAt: new Date().toISOString(),
  });
  console.log('👤 Created new user:', user.email);
 }

 // Generate tokens
 const accessToken = generateAccessToken(user);
 const refreshToken = generateRefreshToken(user);

 // Store refresh token
 db.storeRefreshToken(user.id, refreshToken);

 console.log('🎫 Tokens generated successfully');

 res.json({
  accessToken,
  refreshToken,
 });
};

/**
 * POST /auth/refresh-token
 * Accepts a Refresh Token, validates it, returns a new Access Token.
 */
const refreshAccessToken = async (req, res) => {
 const { refreshToken } = req.body;

 if (!refreshToken) {
  return res.status(400).json({ error: 'refreshToken is required' });
 }

 // Check if token exists in our store
 const storedToken = db.findRefreshToken(refreshToken);
 if (!storedToken) {
  console.log('❌ Refresh token not found in store');
  return res.status(401).json({ error: 'Invalid refresh token' });
 }

 try {
  // Verify the refresh token
  const decoded = jwt.verify(refreshToken, config.refreshTokenSecret);

  // Find user
  const user = db.findUserById(decoded.userId);
  if (!user) {
   console.log('❌ User not found for refresh token');
   return res.status(401).json({ error: 'User not found' });
  }

  // Generate new access token
  const newAccessToken = generateAccessToken(user);

  console.log(`🔄 Access token refreshed for: ${user.email}`);

  res.json({
   accessToken: newAccessToken,
  });
 } catch (error) {
  console.error('❌ Refresh Token Error:', error.message);
  db.removeRefreshToken(refreshToken); // Remove invalid token
  res.status(401).json({ error: 'Invalid or expired refresh token' });
 }
};

/**
 * POST /auth/logout
 * Invalidates the refresh token.
 */
const logout = async (req, res) => {
 const { refreshToken } = req.body;

 if (refreshToken) {
  db.removeRefreshToken(refreshToken);
  console.log('👋 User logged out, refresh token removed');
 }

 res.json({ message: 'Logged out successfully' });
};

module.exports = {
 googleLogin,
 simpleLogin,
 refreshAccessToken,
 logout,
};
