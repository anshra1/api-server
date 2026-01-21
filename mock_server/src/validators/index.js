const { body, validationResult } = require('express-validator');

/**
 * Validation rules for user registration
 */
const validateRegister = [
 body('email')
  .trim()
  .isEmail()
  .withMessage('Please provide a valid email address')
  .normalizeEmail(),
 body('password')
  .isLength({ min: 6 })
  .withMessage('Password must be at least 6 characters long')
  .matches(/\d/)
  .withMessage('Password must contain at least one number'),
 body('name')
  .trim()
  .notEmpty()
  .withMessage('Name is required')
  .isLength({ max: 100 })
  .withMessage('Name must be less than 100 characters'),
];

/**
 * Validation rules for user login
 */
const validateLogin = [
 body('email')
  .trim()
  .notEmpty()
  .withMessage('Email is required'),
 body('password')
  .notEmpty()
  .withMessage('Password is required'),
];

/**
 * Validation rules for creating a task
 */
const validateTask = [
 body('title')
  .trim()
  .notEmpty()
  .withMessage('Title is required')
  .isLength({ max: 200 })
  .withMessage('Title must be less than 200 characters'),
 body('subtitle')
  .optional()
  .trim()
  .isLength({ max: 500 })
  .withMessage('Subtitle must be less than 500 characters'),
 body('priority')
  .optional()
  .isIn(['low', 'medium', 'high'])
  .withMessage('Priority must be low, medium, or high'),
 body('dueDate')
  .optional()
  .isISO8601()
  .withMessage('Due date must be a valid ISO 8601 date'),
 body('category')
  .optional()
  .trim()
  .isLength({ max: 50 })
  .withMessage('Category must be less than 50 characters'),
];

/**
 * Validation rules for updating a task
 */
const validateTaskUpdate = [
 body('title')
  .optional()
  .trim()
  .notEmpty()
  .withMessage('Title cannot be empty')
  .isLength({ max: 200 })
  .withMessage('Title must be less than 200 characters'),
 body('subtitle')
  .optional()
  .trim()
  .isLength({ max: 500 })
  .withMessage('Subtitle must be less than 500 characters'),
 body('isCompleted')
  .optional()
  .isBoolean()
  .withMessage('isCompleted must be a boolean'),
 body('priority')
  .optional()
  .isIn(['low', 'medium', 'high'])
  .withMessage('Priority must be low, medium, or high'),
 body('dueDate')
  .optional()
  .isISO8601()
  .withMessage('Due date must be a valid ISO 8601 date'),
 body('category')
  .optional()
  .trim()
  .isLength({ max: 50 })
  .withMessage('Category must be less than 50 characters'),
];

/**
 * Validation rules for profile update
 */
const validateProfileUpdate = [
 body('name')
  .optional()
  .trim()
  .notEmpty()
  .withMessage('Name cannot be empty')
  .isLength({ max: 100 })
  .withMessage('Name must be less than 100 characters'),
 body('picture')
  .optional()
  .isURL()
  .withMessage('Picture must be a valid URL'),
];

/**
 * Validation rules for password change
 */
const validatePasswordChange = [
 body('currentPassword')
  .notEmpty()
  .withMessage('Current password is required'),
 body('newPassword')
  .isLength({ min: 6 })
  .withMessage('New password must be at least 6 characters long')
  .matches(/\d/)
  .withMessage('New password must contain at least one number'),
];

/**
 * Validation rules for batch operations
 */
const validateBatchIds = [
 body('ids')
  .isArray({ min: 1 })
  .withMessage('ids must be a non-empty array'),
 body('ids.*')
  .isString()
  .withMessage('Each id must be a string'),
];

/**
 * Middleware to handle validation errors
 */
const handleValidationErrors = (req, res, next) => {
 const errors = validationResult(req);

 if (!errors.isEmpty()) {
  const formattedErrors = errors.array().map(err => ({
   field: err.path,
   message: err.msg,
  }));

  return res.status(400).json({
   error: {
    code: 'VALIDATION_ERROR',
    message: 'Validation failed',
    details: formattedErrors,
   },
  });
 }

 next();
};

module.exports = {
 validateRegister,
 validateLogin,
 validateTask,
 validateTaskUpdate,
 validateProfileUpdate,
 validatePasswordChange,
 validateBatchIds,
 handleValidationErrors,
};
