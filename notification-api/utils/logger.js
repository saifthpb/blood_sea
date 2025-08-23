const winston = require('winston');
const path = require('path');

// Create logs directory if it doesn't exist
const fs = require('fs');
const logsDir = path.join(__dirname, '../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Custom format for logs
const logFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss'
  }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.prettyPrint()
);

// Console format for development
const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({
    format: 'HH:mm:ss'
  }),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    let msg = `${timestamp} [${level}]: ${message}`;
    if (Object.keys(meta).length > 0) {
      msg += ` ${JSON.stringify(meta)}`;
    }
    return msg;
  })
);

// Create logger instance
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  defaultMeta: { service: 'blood-sea-notification-api' },
  transports: [
    // Write all logs with level 'error' and below to error.log
    new winston.transports.File({
      filename: path.join(logsDir, 'error.log'),
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
    
    // Write all logs with level 'info' and below to combined.log
    new winston.transports.File({
      filename: path.join(logsDir, 'combined.log'),
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),

    // Write notification-specific logs
    new winston.transports.File({
      filename: path.join(logsDir, 'notifications.log'),
      level: 'info',
      maxsize: 5242880, // 5MB
      maxFiles: 3,
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    })
  ],
});

// Add console transport for development
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: consoleFormat
  }));
}

// Create notification-specific logger
const notificationLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: { service: 'notification-service' },
  transports: [
    new winston.transports.File({
      filename: path.join(logsDir, 'notifications.log'),
      maxsize: 5242880, // 5MB
      maxFiles: 3,
    })
  ]
});

// Helper functions for structured logging
const logNotificationSent = (data) => {
  notificationLogger.info('Notification sent', {
    event: 'notification_sent',
    userId: data.userId,
    type: data.type,
    priority: data.priority,
    success: data.success,
    timestamp: new Date().toISOString()
  });
};

const logNotificationFailed = (data) => {
  notificationLogger.error('Notification failed', {
    event: 'notification_failed',
    userId: data.userId,
    type: data.type,
    error: data.error,
    timestamp: new Date().toISOString()
  });
};

const logBloodRequest = (data) => {
  notificationLogger.info('Blood request notification', {
    event: 'blood_request',
    donorId: data.donorId,
    requesterId: data.requesterId,
    bloodType: data.bloodType,
    urgency: data.urgency,
    location: data.location,
    timestamp: new Date().toISOString()
  });
};

const logBulkNotification = (data) => {
  notificationLogger.info('Bulk notification sent', {
    event: 'bulk_notification',
    userCount: data.userCount,
    successful: data.successful,
    failed: data.failed,
    type: data.type,
    timestamp: new Date().toISOString()
  });
};

// Performance logging
const logPerformance = (operation, duration, metadata = {}) => {
  logger.info('Performance metric', {
    event: 'performance',
    operation,
    duration: `${duration}ms`,
    ...metadata,
    timestamp: new Date().toISOString()
  });
};

// Error logging with context
const logError = (error, context = {}) => {
  logger.error('Application error', {
    event: 'error',
    message: error.message,
    stack: error.stack,
    ...context,
    timestamp: new Date().toISOString()
  });
};

// API request logging
const logApiRequest = (req, res, duration) => {
  logger.info('API request', {
    event: 'api_request',
    method: req.method,
    url: req.originalUrl,
    statusCode: res.statusCode,
    duration: `${duration}ms`,
    userAgent: req.get('User-Agent'),
    ip: req.ip,
    userId: req.user?.uid,
    timestamp: new Date().toISOString()
  });
};

module.exports = {
  logger,
  notificationLogger,
  logNotificationSent,
  logNotificationFailed,
  logBloodRequest,
  logBulkNotification,
  logPerformance,
  logError,
  logApiRequest
};
