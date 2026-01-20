const { v4: uuidv4 } = require('uuid');
const db = require('../models/database');

/**
 * GET /tasks
 * Returns all tasks for the authenticated user.
 */
const getTasks = (req, res) => {
 const userId = req.user.userId;
 const tasks = db.getTasksByUserId(userId);

 console.log(`📋 Fetched ${tasks.length} tasks for user: ${req.user.email}`);

 res.json(tasks);
};

/**
 * POST /tasks
 * Creates a new task for the authenticated user.
 */
const createTask = (req, res) => {
 const userId = req.user.userId;
 const { title, description, isCompleted = false } = req.body;

 if (!title) {
  return res.status(400).json({ error: 'title is required' });
 }

 const task = db.createTask({
  id: uuidv4(),
  userId,
  title,
  description: description || '',
  isCompleted,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
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
 const { title, description, isCompleted } = req.body;

 // Find task
 const existingTask = db.findTaskById(id);

 if (!existingTask) {
  return res.status(404).json({ error: 'Task not found' });
 }

 // Ensure user owns the task
 if (existingTask.userId !== userId) {
  return res.status(403).json({ error: 'You do not have permission to update this task' });
 }

 const updates = {
  ...(title !== undefined && { title }),
  ...(description !== undefined && { description }),
  ...(isCompleted !== undefined && { isCompleted }),
  updatedAt: new Date().toISOString(),
 };

 const updatedTask = db.updateTask(id, updates);

 console.log(`✏️  Task updated: "${updatedTask.title}" for user: ${req.user.email}`);

 res.json(updatedTask);
};

/**
 * DELETE /tasks/:id
 * Deletes a task.
 */
const deleteTask = (req, res) => {
 const { id } = req.params;
 const userId = req.user.userId;

 // Find task
 const existingTask = db.findTaskById(id);

 if (!existingTask) {
  return res.status(404).json({ error: 'Task not found' });
 }

 // Ensure user owns the task
 if (existingTask.userId !== userId) {
  return res.status(403).json({ error: 'You do not have permission to delete this task' });
 }

 db.deleteTask(id);

 console.log(`🗑️  Task deleted: "${existingTask.title}" for user: ${req.user.email}`);

 res.status(204).send();
};

module.exports = {
 getTasks,
 createTask,
 updateTask,
 deleteTask,
};
