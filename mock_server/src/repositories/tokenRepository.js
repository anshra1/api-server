const db = require('../db');

const tokenRepository = {
 /**
  * Store a refresh token
  */
 store: (userId, token, expiresAt) => {
  // Remove old tokens for this user first
  db.prepare('DELETE FROM refresh_tokens WHERE user_id = ?').run(userId);

  // Store new token
  db.prepare(`
      INSERT INTO refresh_tokens (user_id, token, created_at, expires_at)
      VALUES (?, ?, ?, ?)
    `).run(userId, token, new Date().toISOString(), expiresAt);
 },

 /**
  * Find a refresh token
  */
 find: (token) => {
  return db.prepare('SELECT * FROM refresh_tokens WHERE token = ?').get(token);
 },

 /**
  * Remove a refresh token
  */
 remove: (token) => {
  const result = db.prepare('DELETE FROM refresh_tokens WHERE token = ?').run(token);
  return result.changes > 0;
 },

 /**
  * Remove all tokens for a user
  */
 removeAllForUser: (userId) => {
  const result = db.prepare('DELETE FROM refresh_tokens WHERE user_id = ?').run(userId);
  return result.changes;
 },

 /**
  * Clean up expired tokens
  */
 cleanupExpired: () => {
  const result = db.prepare(
   "DELETE FROM refresh_tokens WHERE expires_at < datetime('now')"
  ).run();
  return result.changes;
 },
};

module.exports = tokenRepository;
