const db = require('../db');

const taskRepository = {
 /**
  * Find tasks by user ID with pagination, search, and filters
  */
 findByUserId: (userId, options = {}) => {
  const {
   page = 1,
   limit = 20,
   sort = 'created_at',
   order = 'desc',
   search = '',
   isCompleted = null,
   priority = null,
   category = null,
  } = options;

  const offset = (page - 1) * limit;
  let query = 'SELECT * FROM tasks WHERE user_id = ? AND deleted_at IS NULL';
  let countQuery = 'SELECT COUNT(*) as total FROM tasks WHERE user_id = ? AND deleted_at IS NULL';
  const params = [userId];
  const countParams = [userId];

  // Search in title and subtitle
  if (search) {
   const searchCondition = ' AND (title LIKE ? OR subtitle LIKE ?)';
   query += searchCondition;
   countQuery += searchCondition;
   params.push(`%${search}%`, `%${search}%`);
   countParams.push(`%${search}%`, `%${search}%`);
  }

  // Filter by completion status
  if (isCompleted !== null) {
   const completedCondition = ' AND is_completed = ?';
   query += completedCondition;
   countQuery += completedCondition;
   const completedValue = isCompleted ? 1 : 0;
   params.push(completedValue);
   countParams.push(completedValue);
  }

  // Filter by priority
  if (priority) {
   const priorityCondition = ' AND priority = ?';
   query += priorityCondition;
   countQuery += priorityCondition;
   params.push(priority);
   countParams.push(priority);
  }

  // Filter by category
  if (category) {
   const categoryCondition = ' AND category = ?';
   query += categoryCondition;
   countQuery += categoryCondition;
   params.push(category);
   countParams.push(category);
  }

  // Sorting
  const validSorts = ['created_at', 'due_date', 'title', 'priority', 'updated_at'];
  const sortColumn = validSorts.includes(sort) ? sort : 'created_at';
  const sortOrder = order.toLowerCase() === 'asc' ? 'ASC' : 'DESC';
  query += ` ORDER BY ${sortColumn} ${sortOrder}`;

  // Pagination
  query += ' LIMIT ? OFFSET ?';
  params.push(limit, offset);

  // Execute queries
  const tasks = db.prepare(query).all(...params);
  const { total } = db.prepare(countQuery).get(...countParams);

  // Transform tasks (convert is_completed to boolean)
  const transformedTasks = tasks.map((task) => ({
   id: task.id,
   userId: task.user_id,
   title: task.title,
   subtitle: task.subtitle,
   isCompleted: task.is_completed === 1,
   priority: task.priority,
   dueDate: task.due_date,
   category: task.category,
   createdAt: task.created_at,
   updatedAt: task.updated_at,
  }));

  return {
   tasks: transformedTasks,
   pagination: {
    page,
    limit,
    total,
    totalPages: Math.ceil(total / limit),
   },
  };
 },

 /**
  * Find task by ID
  */
 findById: (id) => {
  const task = db.prepare('SELECT * FROM tasks WHERE id = ? AND deleted_at IS NULL').get(id);

  if (!task) return null;

  return {
   id: task.id,
   userId: task.user_id,
   title: task.title,
   subtitle: task.subtitle,
   isCompleted: task.is_completed === 1,
   priority: task.priority,
   dueDate: task.due_date,
   category: task.category,
   createdAt: task.created_at,
   updatedAt: task.updated_at,
  };
 },

 /**
  * Create a new task
  */
 create: (task) => {
  const stmt = db.prepare(`
      INSERT INTO tasks (id, user_id, title, subtitle, is_completed, priority, due_date, category, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

  stmt.run(
   task.id,
   task.userId,
   task.title,
   task.subtitle || null,
   task.isCompleted ? 1 : 0,
   task.priority || 'medium',
   task.dueDate || null,
   task.category || null,
   task.createdAt
  );

  return taskRepository.findById(task.id);
 },

 /**
  * Update a task
  */
 update: (id, updates) => {
  const fieldMapping = {
   title: 'title',
   subtitle: 'subtitle',
   isCompleted: 'is_completed',
   priority: 'priority',
   dueDate: 'due_date',
   category: 'category',
  };

  const updateFields = [];
  const values = [];

  for (const [key, value] of Object.entries(updates)) {
   const dbKey = fieldMapping[key];
   if (dbKey && value !== undefined) {
    updateFields.push(`${dbKey} = ?`);
    if (key === 'isCompleted') {
     values.push(value ? 1 : 0);
    } else {
     values.push(value);
    }
   }
  }

  if (updateFields.length === 0) {
   return taskRepository.findById(id);
  }

  // Always update updated_at
  updateFields.push('updated_at = ?');
  values.push(new Date().toISOString());

  values.push(id);

  const query = `UPDATE tasks SET ${updateFields.join(', ')} WHERE id = ? AND deleted_at IS NULL`;
  db.prepare(query).run(...values);

  return taskRepository.findById(id);
 },

 /**
  * Soft delete a task
  */
 softDelete: (id) => {
  const result = db.prepare(
   'UPDATE tasks SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL'
  ).run(new Date().toISOString(), id);

  return result.changes > 0;
 },

 /**
  * Hard delete a task (permanent)
  */
 delete: (id) => {
  const result = db.prepare('DELETE FROM tasks WHERE id = ?').run(id);
  return result.changes > 0;
 },

 /**
  * Get task statistics for a user
  */
 getStats: (userId) => {
  const result = db.prepare(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN is_completed = 0 THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN priority = 'high' AND is_completed = 0 THEN 1 ELSE 0 END) as highPriority,
        SUM(CASE WHEN due_date < date('now') AND is_completed = 0 THEN 1 ELSE 0 END) as overdue
      FROM tasks 
      WHERE user_id = ? AND deleted_at IS NULL
    `).get(userId);

  return {
   total: result.total || 0,
   completed: result.completed || 0,
   pending: result.pending || 0,
   highPriority: result.highPriority || 0,
   overdue: result.overdue || 0,
  };
 },

 /**
  * Batch update completion status
  */
 batchUpdateCompletion: (ids, userId, isCompleted) => {
  const placeholders = ids.map(() => '?').join(',');
  const result = db.prepare(`
      UPDATE tasks 
      SET is_completed = ?, updated_at = ?
      WHERE id IN (${placeholders}) AND user_id = ? AND deleted_at IS NULL
    `).run(isCompleted ? 1 : 0, new Date().toISOString(), ...ids, userId);

  return result.changes;
 },

 /**
  * Batch soft delete
  */
 batchSoftDelete: (ids, userId) => {
  const placeholders = ids.map(() => '?').join(',');
  const result = db.prepare(`
      UPDATE tasks 
      SET deleted_at = ?
      WHERE id IN (${placeholders}) AND user_id = ? AND deleted_at IS NULL
    `).run(new Date().toISOString(), ...ids, userId);

  return result.changes;
 },

 /**
  * Get all categories for a user
  */
 getCategories: (userId) => {
  const results = db.prepare(`
      SELECT DISTINCT category 
      FROM tasks 
      WHERE user_id = ? AND category IS NOT NULL AND deleted_at IS NULL
      ORDER BY category
    `).all(userId);

  return results.map((r) => r.category);
 },
};

module.exports = taskRepository;
