const { v4: uuidv4 } = require('uuid');
const taskRepository = require('../repositories/taskRepository');

/**
 * GET /tasks
 * Returns all tasks for the authenticated user with pagination, search, and filters.
 * 
 * Query Parameters:
 * - page: Page number (default: 1)
 * - limit: Items per page (default: 20, max: 100)
 * - sort: Sort field (created_at, due_date, title, priority)
 * - order: Sort order (asc, desc)
 * - search: Search in title and subtitle
 * - isCompleted: Filter by completion status (true, false)
 * - priority: Filter by priority (low, medium, high)
 * - category: Filter by category
 */
const getTasks = (req, res) => {
 const userId = req.user.userId;
 const { page, limit, sort, order, search, isCompleted, priority, category } = req.query;

 const result = taskRepository.findByUserId(userId, {
  page: parseInt(page) || 1,
  limit: Math.min(parseInt(limit) || 20, 100),
  sort,
  order,
  search,
  isCompleted: isCompleted === 'true' ? true : isCompleted === 'false' ? false : null,
  priority,
  category,
 });

 console.log(`📋 Fetched ${result.tasks.length} tasks for user: ${req.user.email} (page ${result.pagination.page}/${result.pagination.totalPages})`);

 res.json(result);
};

/**
 * GET /tasks/stats
 * Returns task statistics for the authenticated user.
 */
const getTaskStats = (req, res) => {
 const userId = req.user.userId;
 const stats = taskRepository.getStats(userId);

 console.log(`📊 Stats fetched for user: ${req.user.email}`);

 res.json(stats);
};

/**
 * GET /tasks/categories
 * Returns all unique categories for the authenticated user.
 */
const getCategories = (req, res) => {
 const userId = req.user.userId;
 const categories = taskRepository.getCategories(userId);

 res.json({ categories });
};

/**
 * GET /tasks/:id
 * Returns a single task by ID.
 */
const getTaskById = (req, res) => {
 const { id } = req.params;
 const userId = req.user.userId;

 const task = taskRepository.findById(id);

 if (!task) {
  return res.status(404).json({
   error: {
    code: 'TASK_NOT_FOUND',
    message: 'Task not found',
   },
  });
 }

 // Ensure user owns the task
 if (task.userId !== userId) {
  return res.status(403).json({
   error: {
    code: 'FORBIDDEN',
    message: 'You do not have permission to view this task',
   },
  });
 }

 res.json(task);
};

/**
 * POST /tasks
 * Creates a new task for the authenticated user.
 */
const createTask = (req, res) => {
 const userId = req.user.userId;
 const { title, subtitle, isCompleted = false, priority, dueDate, category } = req.body;

 const task = taskRepository.create({
  id: uuidv4(),
  userId,
  title,
  subtitle: subtitle || null,
  isCompleted,
  priority: priority || 'medium',
  dueDate: dueDate || null,
  category: category || null,
  createdAt: new Date().toISOString(),
 });

 console.log(`➕ Task created: "${task.title}" for user: ${req.user.email}`);

 res.status(201).json(task);
};

/**
 * PUT /tasks/:id
 * Updates an existing task.
 */
const updateTask = (req, res) => {
 const { id } = req.params;
 const userId = req.user.userId;
 const { title, subtitle, isCompleted, priority, dueDate, category } = req.body;

 // Find task
 const existingTask = taskRepository.findById(id);

 if (!existingTask) {
  return res.status(404).json({
   error: {
    code: 'TASK_NOT_FOUND',
    message: 'Task not found',
   },
  });
 }

 // Ensure user owns the task
 if (existingTask.userId !== userId) {
  return res.status(403).json({
   error: {
    code: 'FORBIDDEN',
    message: 'You do not have permission to update this task',
   },
  });
 }

 const updates = {};
 if (title !== undefined) updates.title = title;
 if (subtitle !== undefined) updates.subtitle = subtitle;
 if (isCompleted !== undefined) updates.isCompleted = isCompleted;
 if (priority !== undefined) updates.priority = priority;
 if (dueDate !== undefined) updates.dueDate = dueDate;
 if (category !== undefined) updates.category = category;

 const updatedTask = taskRepository.update(id, updates);

 console.log(`✏️  Task updated: "${updatedTask.title}" for user: ${req.user.email}`);

 res.json(updatedTask);
};

/**
 * DELETE /tasks/:id
 * Soft deletes a task.
 */
const deleteTask = (req, res) => {
 const { id } = req.params;
 const userId = req.user.userId;

 // Find task
 const existingTask = taskRepository.findById(id);

 if (!existingTask) {
  return res.status(404).json({
   error: {
    code: 'TASK_NOT_FOUND',
    message: 'Task not found',
   },
  });
 }

 // Ensure user owns the task
 if (existingTask.userId !== userId) {
  return res.status(403).json({
   error: {
    code: 'FORBIDDEN',
    message: 'You do not have permission to delete this task',
   },
  });
 }

 taskRepository.softDelete(id);

 console.log(`🗑️  Task deleted: "${existingTask.title}" for user: ${req.user.email}`);

 res.status(204).send();
};

/**
 * POST /tasks/batch/complete
 * Batch update completion status for multiple tasks.
 */
const batchComplete = (req, res) => {
 const userId = req.user.userId;
 const { ids, isCompleted } = req.body;

 if (!Array.isArray(ids) || ids.length === 0) {
  return res.status(400).json({
   error: {
    code: 'INVALID_INPUT',
    message: 'ids must be a non-empty array',
   },
  });
 }

 if (typeof isCompleted !== 'boolean') {
  return res.status(400).json({
   error: {
    code: 'INVALID_INPUT',
    message: 'isCompleted must be a boolean',
   },
  });
 }

 const updatedCount = taskRepository.batchUpdateCompletion(ids, userId, isCompleted);

 console.log(`✅ Batch complete: ${updatedCount} tasks updated for user: ${req.user.email}`);

 res.json({
  message: `${updatedCount} tasks updated`,
  updated: updatedCount,
 });
};

/**
 * DELETE /tasks/batch
 * Batch soft delete multiple tasks.
 */
const batchDelete = (req, res) => {
 const userId = req.user.userId;
 const { ids } = req.body;

 if (!Array.isArray(ids) || ids.length === 0) {
  return res.status(400).json({
   error: {
    code: 'INVALID_INPUT',
    message: 'ids must be a non-empty array',
   },
  });
 }

 const deletedCount = taskRepository.batchSoftDelete(ids, userId);

 console.log(`🗑️  Batch delete: ${deletedCount} tasks deleted for user: ${req.user.email}`);

 res.json({
  message: `${deletedCount} tasks deleted`,
  deleted: deletedCount,
 });
};

module.exports = {
 getTasks,
 getTaskById,
 getTaskStats,
 getCategories,
 createTask,
 updateTask,
 deleteTask,
 batchComplete,
 batchDelete,
};
