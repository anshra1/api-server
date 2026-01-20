const express = require('express');
const taskController = require('../controllers/taskController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// All task routes require authentication
router.use(authMiddleware);

// GET /tasks - Get all tasks for user
router.get('/', taskController.getTasks);

// POST /tasks - Create a new task
router.post('/', taskController.createTask);

// PUT /tasks/:id - Update a task
router.put('/:id', taskController.updateTask);

// DELETE /tasks/:id - Delete a task
router.delete('/:id', taskController.deleteTask);

module.exports = router;
