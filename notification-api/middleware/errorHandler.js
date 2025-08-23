const { logger } = require('../utils/logger');

/**
 * Global error handling middleware
 */
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  logger.error('API Error:', {
    message: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    userId: req.user?.uid,
    body: req.body,
    params: req.params,
    query: req.query
  });

  // Firebase Admin SDK errors
  if (err.code && err.code.startsWith('auth/')) {
    return res.status(401).json({
      success: false,
      message: 'Authentication error',
      error: err.code
    });
  }

  // Firebase Messaging errors
  if (err.code && err.code.startsWith('messaging/')) {
    let statusCode = 400;
    let message = 'Messaging error';

    switch (err.code) {
      case 'messaging/registration-token-not-registered':
        statusCode = 404;
        message = 'Device token not registered';
        break;
      case 'messaging/invalid-registration-token':
        statusCode = 400;
        message = 'Invalid device token';
        break;
      case 'messaging/message-rate-exceeded':
        statusCode = 429;
        message = 'Message rate exceeded';
        break;
      case 'messaging/device-message-rate-exceeded':
        statusCode = 429;
        message = 'Device message rate exceeded';
        break;
      case 'messaging/topics-message-rate-exceeded':
        statusCode = 429;
        message = 'Topics message rate exceeded';
        break;
      case 'messaging/invalid-package-name':
        statusCode = 400;
        message = 'Invalid package name';
        break;
      case 'messaging/invalid-apns-credentials':
        statusCode = 400;
        message = 'Invalid APNS credentials';
        break;
    }

    return res.status(statusCode).json({
      success: false,
      message,
      error: err.code
    });
  }

  // Firestore errors
  if (err.code && err.code.startsWith('firestore/')) {
    return res.status(500).json({
      success: false,
      message: 'Database error',
      error: 'Internal server error'
    });
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message);
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      errors: message
    });
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      message: 'Invalid token'
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      message: 'Token expired'
    });
  }

  // Mongoose bad ObjectId
  if (err.name === 'CastError') {
    return res.status(400).json({
      success: false,
      message: 'Invalid ID format'
    });
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return res.status(400).json({
      success: false,
      message: `Duplicate ${field} entered`
    });
  }

  // Rate limiting errors
  if (err.status === 429) {
    return res.status(429).json({
      success: false,
      message: 'Too many requests, please try again later'
    });
  }

  // Default error
  res.status(error.statusCode || 500).json({
    success: false,
    message: error.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

/**
 * Handle async errors
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

/**
 * Handle 404 errors
 */
const notFound = (req, res, next) => {
  const error = new Error(`Not found - ${req.originalUrl}`);
  res.status(404);
  next(error);
};

module.exports = {
  errorHandler,
  asyncHandler,
  notFound
};
