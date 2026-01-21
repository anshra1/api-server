/**
 * Global Error Handler Middleware
 * Catches all errors and returns a consistent JSON response.
 */
const errorHandler = (err, req, res, next) => {
 console.error('🔥 Error:', err.message);

 // Log stack trace in development
 if (process.env.NODE_ENV === 'development') {
  console.error(err.stack);
 }

 // Determine status code
 const statusCode = err.statusCode || err.status || 500;

 // Determine error code
 let code = err.code || 'INTERNAL_ERROR';

 // Handle specific error types
 if (err.name === 'JsonWebTokenError') {
  code = 'INVALID_TOKEN';
 } else if (err.name === 'TokenExpiredError') {
  code = 'TOKEN_EXPIRED';
 } else if (err.name === 'ValidationError') {
  code = 'VALIDATION_ERROR';
 } else if (err.code === 'SQLITE_CONSTRAINT') {
  code = 'CONSTRAINT_ERROR';
 }

 // Build error response
 const errorResponse = {
  error: {
   code,
   message: err.message || 'An unexpected error occurred',
  },
 };

 // Add stack trace in development mode
 if (process.env.NODE_ENV === 'development') {
  errorResponse.error.stack = err.stack;
 }

 // Add validation details if available
 if (err.details) {
  errorResponse.error.details = err.details;
 }

 res.status(statusCode).json(errorResponse);
};

/**
 * Custom Error Class for API errors
 */
class ApiError extends Error {
 constructor(message, statusCode = 500, code = 'INTERNAL_ERROR') {
  super(message);
  this.statusCode = statusCode;
  this.code = code;
  this.name = 'ApiError';
  Error.captureStackTrace(this, this.constructor);
 }

 static badRequest(message = 'Bad request', code = 'BAD_REQUEST') {
  return new ApiError(message, 400, code);
 }

 static unauthorized(message = 'Unauthorized', code = 'UNAUTHORIZED') {
  return new ApiError(message, 401, code);
 }

 static forbidden(message = 'Forbidden', code = 'FORBIDDEN') {
  return new ApiError(message, 403, code);
 }

 static notFound(message = 'Not found', code = 'NOT_FOUND') {
  return new ApiError(message, 404, code);
 }

 static conflict(message = 'Conflict', code = 'CONFLICT') {
  return new ApiError(message, 409, code);
 }

 static tooManyRequests(message = 'Too many requests', code = 'RATE_LIMITED') {
  return new ApiError(message, 429, code);
 }

 static internal(message = 'Internal server error', code = 'INTERNAL_ERROR') {
  return new ApiError(message, 500, code);
 }
}

module.exports = errorHandler;
module.exports.ApiError = ApiError;
