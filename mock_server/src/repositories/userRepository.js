const db = require('../db');

const userRepository = {
 /**
  * Find user by email
  */
 findByEmail: (email) => {
  return db.prepare('SELECT * FROM users WHERE email = ?').get(email);
 },

 /**
  * Find user by ID
  */
 findById: (id) => {
  return db.prepare('SELECT * FROM users WHERE id = ?').get(id);
 },

 /**
  * Find user by Google ID
  */
 findByGoogleId: (googleId) => {
  return db.prepare('SELECT * FROM users WHERE google_id = ?').get(googleId);
 },

 /**
  * Create a new user
  */
 create: (user) => {
  const stmt = db.prepare(`
      INSERT INTO users (id, email, password, name, picture, google_id, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);

  stmt.run(
   user.id,
   user.email,
   user.password || null,
   user.name,
   user.picture || null,
   user.googleId || null,
   user.createdAt
  );

  return userRepository.findById(user.id);
 },

 /**
  * Update user by ID
  */
 update: (id, updates) => {
  const allowedFields = ['name', 'picture', 'password', 'updated_at'];
  const updateFields = [];
  const values = [];

  // Build dynamic update query
  for (const [key, value] of Object.entries(updates)) {
   const dbKey = key === 'updatedAt' ? 'updated_at' : key;
   if (allowedFields.includes(dbKey) && value !== undefined) {
    updateFields.push(`${dbKey} = ?`);
    values.push(value);
   }
  }

  if (updateFields.length === 0) {
   return userRepository.findById(id);
  }

  // Always update updated_at
  updateFields.push('updated_at = ?');
  values.push(new Date().toISOString());

  values.push(id);

  const query = `UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`;
  db.prepare(query).run(...values);

  return userRepository.findById(id);
 },

 /**
  * Delete user by ID
  */
 delete: (id) => {
  const result = db.prepare('DELETE FROM users WHERE id = ?').run(id);
  return result.changes > 0;
 },
};

module.exports = userRepository;
