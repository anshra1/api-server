const express = require('express');
const taskController = require('../controllers/taskController');
const authMiddleware = require('../middleware/authMiddleware');
const {
 validateTask,
 validateTaskUpdate,
 validateBatchIds,
 handleValidationErrors,
} = require('../validators');

const router = express.Router();

// All task routes require authentication
router.use(authMiddleware);

// GET /tasks/stats - Get task statistics (MUST be before /:id route)
router.get('/stats', taskController.getTaskStats);

// GET /tasks/categories - Get all categories
router.get('/categories', taskController.getCategories);

// POST /tasks/batch/complete - Batch update completion status
router.post(
 '/batch/complete',
 validateBatchIds,
 handleValidationErrors,
 taskController.batchComplete
);

// DELETE /tasks/batch - Batch delete tasks
router.delete(
 '/batch',
 validateBatchIds,
 handleValidationErrors,
 taskController.batchDelete
);

// GET /tasks - Get all tasks for user (with pagination, search, filters)
router.get('/', taskController.getTasks);

// GET /tasks/:id - Get a single task
router.get('/:id', taskController.getTaskById);

// POST /tasks - Create a new task
router.post('/', validateTask, handleValidationErrors, taskController.createTask);

// PUT /tasks/:id - Update a task
router.put('/:id', validateTaskUpdate, handleValidationErrors, taskController.updateTask);

// DELETE /tasks/:id - Delete a task (soft delete)
router.delete('/:id', taskController.deleteTask);

module.exports = router;
