const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
const { OAuth2Client } = require('google-auth-library');
const config = require('../config');
const userRepository = require('../repositories/userRepository');
const tokenRepository = require('../repositories/tokenRepository');

const googleClient = new OAuth2Client(config.googleClientId);
const SALT_ROUNDS = 10;

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
 * Calculate token expiry date
 */
const getRefreshTokenExpiry = () => {
 const expiry = config.refreshTokenExpiry;
 const match = expiry.match(/(\d+)([smhd])/);
 if (!match) return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // Default 7 days

 const value = parseInt(match[1]);
 const unit = match[2];
 const multipliers = { s: 1000, m: 60000, h: 3600000, d: 86400000 };

 return new Date(Date.now() + value * multipliers[unit]).toISOString();
};

/**
 * POST /auth/register
 * Register a new user with email and password
 */
const register = async (req, res) => {
 const { email, password, name } = req.body;

 console.log(`📝 Registration attempt for: ${email}`);

 // Check if user already exists
 const existingUser = userRepository.findByEmail(email);
 if (existingUser) {
  console.log(`❌ Email already registered: ${email}`);
  return res.status(409).json({
   error: {
    code: 'EMAIL_EXISTS',
    message: 'This email is already registered',
   },
  });
 }

 // Hash password
 const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

 // Create user
 const user = userRepository.create({
  id: uuidv4(),
  email,
  password: hashedPassword,
  name,
  createdAt: new Date().toISOString(),
 });

 // Generate tokens
 const accessToken = generateAccessToken(user);
 const refreshToken = generateRefreshToken(user);

 // Store refresh token
 tokenRepository.store(user.id, refreshToken, getRefreshTokenExpiry());

 console.log(`✅ User registered: ${email}`);

 res.status(201).json({
  accessToken,
  refreshToken,
  user: {
   id: user.id,
   email: user.email,
   name: user.name,
  },
 });
};

/**
 * POST /auth/login
 * Login with email and password
 */
const login = async (req, res) => {
 const { email, password } = req.body;

 console.log(`🔐 Login attempt for: ${email}`);

 // Find user
 const user = userRepository.findByEmail(email);
 if (!user) {
  console.log(`❌ User not found: ${email}`);
  return res.status(401).json({
   error: {
    code: 'INVALID_CREDENTIALS',
    message: 'Invalid email or password',
   },
  });
 }

 // Check if user has a password (might be Google-only user)
 if (!user.password) {
  console.log(`❌ User has no password (Google-only): ${email}`);
  return res.status(401).json({
   error: {
    code: 'GOOGLE_ONLY_ACCOUNT',
    message: 'This account uses Google Sign-In. Please login with Google.',
   },
  });
 }

 // Verify password
 const validPassword = await bcrypt.compare(password, user.password);
 if (!validPassword) {
  console.log(`❌ Invalid password for: ${email}`);
  return res.status(401).json({
   error: {
    code: 'INVALID_CREDENTIALS',
    message: 'Invalid email or password',
   },
  });
 }

 // Generate tokens
 const accessToken = generateAccessToken(user);
 const refreshToken = generateRefreshToken(user);

 // Store refresh token
 tokenRepository.store(user.id, refreshToken, getRefreshTokenExpiry());

 console.log(`✅ User logged in: ${email}`);

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
};

/**
 * POST /auth/google
 * Accepts a Google ID Token, verifies it, creates/finds user, returns tokens.
 */
const googleLogin = async (req, res) => {
 const { idToken } = req.body;

 if (!idToken) {
  return res.status(400).json({
   error: {
    code: 'MISSING_TOKEN',
    message: 'idToken is required',
   },
  });
 }

 try {
  console.log('🔍 Verifying Google ID Token...');

  let payload;

  // If GOOGLE_CLIENT_ID is not set, we'll skip verification for testing
  if (!config.googleClientId || config.googleClientId.includes('YOUR_GOOGLE')) {
   console.log('⚠️  GOOGLE_CLIENT_ID not configured. Skipping verification (DEV MODE).');

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
  let user = userRepository.findByEmail(payload.email);

  if (!user) {
   console.log('👤 Creating new user...');
   user = userRepository.create({
    id: uuidv4(),
    email: payload.email,
    name: payload.name || 'Unknown',
    picture: payload.picture || null,
    googleId: payload.sub,
    createdAt: new Date().toISOString(),
   });
  } else {
   console.log('👤 Existing user found:', user.email);
   // Update Google ID if not set
   if (!user.google_id) {
    userRepository.update(user.id, { google_id: payload.sub });
   }
  }

  // Generate tokens
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  // Store refresh token
  tokenRepository.store(user.id, refreshToken, getRefreshTokenExpiry());

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
  res.status(401).json({
   error: {
    code: 'INVALID_GOOGLE_TOKEN',
    message: 'Invalid Google ID Token',
   },
  });
 }
};

/**
 * POST /auth/refresh-token
 * Accepts a Refresh Token, validates it, returns a new Access Token.
 */
const refreshAccessToken = async (req, res) => {
 const { refreshToken } = req.body;

 if (!refreshToken) {
  return res.status(400).json({
   error: {
    code: 'MISSING_TOKEN',
    message: 'refreshToken is required',
   },
  });
 }

 // Check if token exists in our store
 const storedToken = tokenRepository.find(refreshToken);
 if (!storedToken) {
  console.log('❌ Refresh token not found in store');
  return res.status(401).json({
   error: {
    code: 'INVALID_TOKEN',
    message: 'Invalid refresh token',
   },
  });
 }

 try {
  // Verify the refresh token
  const decoded = jwt.verify(refreshToken, config.refreshTokenSecret);

  // Find user
  const user = userRepository.findById(decoded.userId);
  if (!user) {
   console.log('❌ User not found for refresh token');
   return res.status(401).json({
    error: {
     code: 'USER_NOT_FOUND',
     message: 'User not found',
    },
   });
  }

  // Generate new access token
  const newAccessToken = generateAccessToken(user);

  console.log(`🔄 Access token refreshed for: ${user.email}`);

  res.json({
   accessToken: newAccessToken,
  });
 } catch (error) {
  console.error('❌ Refresh Token Error:', error.message);
  tokenRepository.remove(refreshToken); // Remove invalid token
  res.status(401).json({
   error: {
    code: 'INVALID_TOKEN',
    message: 'Invalid or expired refresh token',
   },
  });
 }
};

/**
 * POST /auth/logout
 * Invalidates the refresh token.
 */
const logout = async (req, res) => {
 const { refreshToken } = req.body;

 if (refreshToken) {
  tokenRepository.remove(refreshToken);
  console.log('👋 User logged out, refresh token removed');
 }

 res.json({ message: 'Logged out successfully' });
};

/**
 * PUT /auth/change-password
 * Change user password (requires authentication)
 */
const changePassword = async (req, res) => {
 const { currentPassword, newPassword } = req.body;
 const userId = req.user.userId;

 console.log(`🔑 Password change attempt for user: ${userId}`);

 // Find user
 const user = userRepository.findById(userId);
 if (!user) {
  return res.status(404).json({
   error: {
    code: 'USER_NOT_FOUND',
    message: 'User not found',
   },
  });
 }

 // Check if user has a password
 if (!user.password) {
  return res.status(400).json({
   error: {
    code: 'NO_PASSWORD',
    message: 'This account uses Google Sign-In and has no password to change.',
   },
  });
 }

 // Verify current password
 const validPassword = await bcrypt.compare(currentPassword, user.password);
 if (!validPassword) {
  console.log(`❌ Invalid current password for user: ${userId}`);
  return res.status(401).json({
   error: {
    code: 'INVALID_PASSWORD',
    message: 'Current password is incorrect',
   },
  });
 }

 // Hash new password
 const hashedPassword = await bcrypt.hash(newPassword, SALT_ROUNDS);

 // Update password
 userRepository.update(userId, { password: hashedPassword });

 // Invalidate all refresh tokens for this user
 tokenRepository.removeAllForUser(userId);

 console.log(`✅ Password changed for user: ${userId}`);

 res.json({ message: 'Password changed successfully. Please login again.' });
};

module.exports = {
 register,
 login,
 googleLogin,
 refreshAccessToken,
 logout,
 changePassword,
};
