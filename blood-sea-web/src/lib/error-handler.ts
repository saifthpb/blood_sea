import { NextRequest, NextResponse } from 'next/server';
import { logger } from './logger';
import { z } from 'zod';

// Error response interface
export interface ErrorResponse {
  success: false;
  message: string;
  error?: string;
  details?: any;
}

// Standard error codes
export const ErrorCodes = {
  // Authentication errors
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  TOKEN_EXPIRED: 'TOKEN_EXPIRED',
  TOKEN_INVALID: 'TOKEN_INVALID',
  
  // Validation errors
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  MISSING_FIELDS: 'MISSING_FIELDS',
  INVALID_FORMAT: 'INVALID_FORMAT',
  
  // Resource errors
  NOT_FOUND: 'NOT_FOUND',
  ALREADY_EXISTS: 'ALREADY_EXISTS',
  
  // Firebase errors
  FIREBASE_ERROR: 'FIREBASE_ERROR',
  FIRESTORE_ERROR: 'FIRESTORE_ERROR',
  MESSAGING_ERROR: 'MESSAGING_ERROR',
  
  // Rate limiting
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',
  
  // Server errors
  INTERNAL_SERVER_ERROR: 'INTERNAL_SERVER_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE'
};

/**
 * Create standardized error response
 */
export function createErrorResponse(
  message: string,
  statusCode: number = 500,
  errorCode?: string,
  details?: any
): NextResponse {
  const response: ErrorResponse = {
    success: false,
    message,
    ...(errorCode && { error: errorCode }),
    ...(details && { details })
  };

  return NextResponse.json(response, { status: statusCode });
}

/**
 * Handle Firebase Authentication errors
 */
export function handleAuthError(error: any): NextResponse {
  logger.error('Authentication error:', error);
  
  let statusCode = 401;
  let message = 'Authentication error';
  let errorCode = ErrorCodes.UNAUTHORIZED;

  if (error.code && error.code.startsWith('auth/')) {
    switch (error.code) {
      case 'auth/id-token-expired':
        message = 'Token has expired';
        errorCode = ErrorCodes.TOKEN_EXPIRED;
        break;
      case 'auth/id-token-revoked':
        message = 'Token has been revoked';
        errorCode = ErrorCodes.TOKEN_INVALID;
        break;
      case 'auth/invalid-id-token':
        message = 'Invalid token format';
        errorCode = ErrorCodes.TOKEN_INVALID;
        break;
      case 'auth/insufficient-permission':
        statusCode = 403;
        message = 'Insufficient permissions';
        errorCode = ErrorCodes.FORBIDDEN;
        break;
      default:
        message = 'Invalid or expired token';
        errorCode = ErrorCodes.TOKEN_INVALID;
    }
  }

  return createErrorResponse(message, statusCode, errorCode, error.code);
}

/**
 * Handle Firebase Messaging errors
 */
export function handleMessagingError(error: any): NextResponse {
  logger.error('Messaging error:', error);
  
  let statusCode = 400;
  let message = 'Messaging error';
  let errorCode = ErrorCodes.MESSAGING_ERROR;

  if (error.code && error.code.startsWith('messaging/')) {
    switch (error.code) {
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
        errorCode = ErrorCodes.RATE_LIMIT_EXCEEDED;
        break;
      case 'messaging/device-message-rate-exceeded':
        statusCode = 429;
        message = 'Device message rate exceeded';
        errorCode = ErrorCodes.RATE_LIMIT_EXCEEDED;
        break;
      case 'messaging/topics-message-rate-exceeded':
        statusCode = 429;
        message = 'Topics message rate exceeded';
        errorCode = ErrorCodes.RATE_LIMIT_EXCEEDED;
        break;
      case 'messaging/invalid-package-name':
        statusCode = 400;
        message = 'Invalid package name';
        break;
      case 'messaging/invalid-apns-credentials':
        statusCode = 400;
        message = 'Invalid APNS credentials';
        break;
      default:
        message = 'Messaging service error';
    }
  }

  return createErrorResponse(message, statusCode, errorCode, error.code);
}

/**
 * Handle Firestore errors
 */
export function handleFirestoreError(error: any): NextResponse {
  logger.error('Firestore error:', error);
  
  let statusCode = 500;
  let message = 'Database error';
  let errorCode = ErrorCodes.FIRESTORE_ERROR;

  if (error.code) {
    switch (error.code) {
      case 'permission-denied':
        statusCode = 403;
        message = 'Permission denied';
        errorCode = ErrorCodes.FORBIDDEN;
        break;
      case 'not-found':
        statusCode = 404;
        message = 'Document not found';
        errorCode = ErrorCodes.NOT_FOUND;
        break;
      case 'already-exists':
        statusCode = 409;
        message = 'Document already exists';
        errorCode = ErrorCodes.ALREADY_EXISTS;
        break;
      case 'resource-exhausted':
        statusCode = 429;
        message = 'Resource exhausted';
        errorCode = ErrorCodes.RATE_LIMIT_EXCEEDED;
        break;
      case 'deadline-exceeded':
        statusCode = 504;
        message = 'Request timeout';
        break;
      case 'unavailable':
        statusCode = 503;
        message = 'Service temporarily unavailable';
        errorCode = ErrorCodes.SERVICE_UNAVAILABLE;
        break;
      default:
        message = 'Internal server error';
        errorCode = ErrorCodes.INTERNAL_SERVER_ERROR;
    }
  }

  return createErrorResponse(message, statusCode, errorCode);
}

/**
 * Handle validation errors
 */
export function handleValidationError(error: z.ZodError): NextResponse {
  logger.warn('Validation error:', error);
  
  const errors = error.errors.map(err => ({
    field: err.path.join('.') || 'root',
    message: err.message
  }));

  return NextResponse.json(
    {
      success: false,
      message: 'Validation errors',
      error: ErrorCodes.VALIDATION_ERROR,
      errors
    },
    { status: 400 }
  );
}

/**
 * Handle rate limiting errors
 */
export function handleRateLimitError(retryAfter?: number): NextResponse {
  const headers: Record<string, string> = {};
  
  if (retryAfter) {
    headers['Retry-After'] = retryAfter.toString();
  }

  return NextResponse.json(
    {
      success: false,
      message: 'Too many requests, please try again later',
      error: ErrorCodes.RATE_LIMIT_EXCEEDED,
      ...(retryAfter && { retryAfter })
    },
    { 
      status: 429,
      headers
    }
  );
}

/**
 * Global error handler for API routes
 */
export function handleApiError(error: any, request: NextRequest): NextResponse {
  // Log error with context
  logger.error('API Error:', {
    message: error.message,
    stack: error.stack,
    url: request.url,
    method: request.method,
    headers: Object.fromEntries(request.headers.entries()),
    timestamp: new Date().toISOString()
  });

  // Handle specific error types
  if (error.code && error.code.startsWith('auth/')) {
    return handleAuthError(error);
  }

  if (error.code && error.code.startsWith('messaging/')) {
    return handleMessagingError(error);
  }

  if (error.code && error.code.startsWith('firestore/')) {
    return handleFirestoreError(error);
  }

  if (error instanceof z.ZodError) {
    return handleValidationError(error);
  }

  // Handle JSON parsing errors
  if (error instanceof SyntaxError && error.message.includes('JSON')) {
    return createErrorResponse(
      'Invalid JSON in request body',
      400,
      ErrorCodes.INVALID_FORMAT
    );
  }

  // Handle network errors
  if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
    return createErrorResponse(
      'Service temporarily unavailable',
      503,
      ErrorCodes.SERVICE_UNAVAILABLE
    );
  }

  // Default error response
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  return createErrorResponse(
    error.message || 'Internal server error',
    500,
    ErrorCodes.INTERNAL_SERVER_ERROR,
    isDevelopment ? { stack: error.stack } : undefined
  );
}

/**
 * Async handler wrapper that catches errors
 */
export function asyncHandler(
  handler: (request: NextRequest) => Promise<NextResponse>
) {
  return async (request: NextRequest): Promise<NextResponse> => {
    try {
      return await handler(request);
    } catch (error) {
      return handleApiError(error, request);
    }
  };
}

/**
 * Higher-order function to wrap API routes with error handling
 */
export function withErrorHandler(
  handler: (request: NextRequest) => Promise<NextResponse>
) {
  return asyncHandler(handler);
}

/**
 * Create not found error response
 */
export function createNotFoundError(resource: string = 'Resource'): NextResponse {
  return createErrorResponse(
    `${resource} not found`,
    404,
    ErrorCodes.NOT_FOUND
  );
}

/**
 * Create forbidden error response
 */
export function createForbiddenError(message: string = 'Access denied'): NextResponse {
  return createErrorResponse(
    message,
    403,
    ErrorCodes.FORBIDDEN
  );
}

/**
 * Create bad request error response
 */
export function createBadRequestError(message: string = 'Bad request'): NextResponse {
  return createErrorResponse(
    message,
    400,
    ErrorCodes.VALIDATION_ERROR
  );
}

/**
 * Create conflict error response
 */
export function createConflictError(message: string = 'Resource already exists'): NextResponse {
  return createErrorResponse(
    message,
    409,
    ErrorCodes.ALREADY_EXISTS
  );
}

/**
 * Handle HTTP method not allowed
 */
export function createMethodNotAllowedError(allowedMethods: string[] = []): NextResponse {
  return NextResponse.json(
    {
      success: false,
      message: 'Method not allowed',
      error: 'METHOD_NOT_ALLOWED',
      allowedMethods
    },
    { 
      status: 405,
      headers: {
        Allow: allowedMethods.join(', ')
      }
    }
  );
}

/**
 * Validate request method
 */
export function validateMethod(request: NextRequest, allowedMethods: string[]): boolean {
  return allowedMethods.includes(request.method);
}

/**
 * Helper to ensure method is allowed
 */
export function requireMethods(
  allowedMethods: string[],
  handler: (request: NextRequest) => Promise<NextResponse>
) {
  return async (request: NextRequest): Promise<NextResponse> => {
    if (!validateMethod(request, allowedMethods)) {
      return createMethodNotAllowedError(allowedMethods);
    }
    return handler(request);
  };
}

export default {
  createErrorResponse,
  handleApiError,
  handleAuthError,
  handleMessagingError,
  handleFirestoreError,
  handleValidationError,
  handleRateLimitError,
  asyncHandler,
  withErrorHandler,
  createNotFoundError,
  createForbiddenError,
  createBadRequestError,
  createConflictError,
  createMethodNotAllowedError,
  validateMethod,
  requireMethods,
  ErrorCodes
};
