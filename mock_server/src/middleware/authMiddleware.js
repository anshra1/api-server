const jwt = require('jsonwebtoken');
const config = require('../config');

/**
 * Authentication Middleware
 * Verifies the Access Token from the Authorization header.
 * Attaches decoded user info to req.user if valid.
 */
const authMiddleware = (req, res, next) => {
 const authHeader = req.headers['authorization'];

 if (!authHeader) {
  console.log('❌ No Authorization header provided');
  return res.status(401).json({ error: 'Access denied. No token provided.' });
 }

 // Expected format: "Bearer <token>"
 const parts = authHeader.split(' ');
 if (parts.length !== 2 || parts[0] !== 'Bearer') {
  console.log('❌ Invalid Authorization header format');
  return res.status(401).json({ error: 'Invalid authorization format. Use: Bearer <token>' });
 }

 const token = parts[1];

 try {
  const decoded = jwt.verify(token, config.accessTokenSecret);
  req.user = decoded; // { userId, email, iat, exp }
  console.log(`✅ Token valid for user: ${decoded.email}`);
  next();
 } catch (error) {
  if (error.name === 'TokenExpiredError') {
   console.log('⏰ Token expired');
   return res.status(401).json({ error: 'Token expired.' });
  }
  console.log('❌ Invalid token:', error.message);
  return res.status(401).json({ error: 'Invalid token.' });
 }
};

module.exports = authMiddleware;
