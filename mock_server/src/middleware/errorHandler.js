/**
 * Global Error Handler Middleware
 * Catches all errors and returns a consistent JSON response.
 */
const errorHandler = (err, req, res, next) => {
 console.error('🔥 Error:', err.message);
 console.error(err.stack);

 const statusCode = err.statusCode || 500;
 const message = err.message || 'Internal Server Error';

 res.status(statusCode).json({
  error: message,
  ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
 });
};

module.exports = errorHandler;
