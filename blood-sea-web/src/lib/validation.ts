import { z } from 'zod';
import { NextRequest, NextResponse } from 'next/server';

// Common validation schemas
export const fcmTokenSchema = z.object({
  fcmToken: z.string().min(1, 'FCM token is required'),
  platform: z.enum(['android', 'ios', 'web']).optional()
});

export const notificationSettingsSchema = z.object({
  bloodRequests: z.boolean().optional(),
  emergencyRequests: z.boolean().optional(),
  generalAnnouncements: z.boolean().optional(),
  donationReminders: z.boolean().optional(),
  soundEnabled: z.boolean().optional(),
  vibrationEnabled: z.boolean().optional()
});

export const testNotificationSchema = z.object({
  message: z.string().optional()
});

export const availabilitySchema = z.object({
  isAvailable: z.boolean()
});

export const sendNotificationSchema = z.object({
  userId: z.string().optional(),
  fcmToken: z.string().optional(),
  title: z.string().min(1, 'Title is required'),
  body: z.string().min(1, 'Body is required'),
  data: z.record(z.string()).optional(),
  priority: z.enum(['low', 'normal', 'high', 'critical']).optional(),
  type: z.string().optional()
}).refine(data => data.userId || data.fcmToken, {
  message: 'Either userId or fcmToken is required'
});

export const bulkNotificationSchema = z.object({
  userIds: z.array(z.string()).optional(),
  fcmTokens: z.array(z.string()).optional(),
  title: z.string().min(1, 'Title is required'),
  body: z.string().min(1, 'Body is required'),
  data: z.record(z.string()).optional(),
  priority: z.enum(['low', 'normal', 'high', 'critical']).optional(),
  type: z.string().optional()
}).refine(data => (data.userIds && data.userIds.length > 0) || (data.fcmTokens && data.fcmTokens.length > 0), {
  message: 'Either userIds or fcmTokens array is required'
});

export const bloodRequestSchema = z.object({
  bloodType: z.enum(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
  hospital: z.string().min(1, 'Hospital name is required'),
  urgency: z.enum(['low', 'normal', 'high', 'critical']),
  location: z.string().optional(),
  contactInfo: z.string().optional(),
  requesterId: z.string().min(1, 'Requester ID is required')
});

// Validation error response type
export interface ValidationErrorResponse {
  success: false;
  message: string;
  errors: Array<{
    field: string;
    message: string;
  }>;
}

// Success response type
export interface ValidationResult<T> {
  success: true;
  data: T;
}

// Validation result type
export type ValidateResult<T> = ValidationResult<T> | ValidationErrorResponse;

/**
 * Validate request body against a Zod schema
 */
export async function validateRequestBody<T>(
  request: NextRequest, 
  schema: z.ZodSchema<T>
): Promise<ValidateResult<T>> {
  try {
    const body = await request.json();
    const result = schema.safeParse(body);
    
    if (!result.success) {
      const errors = result.error.errors.map(err => ({
        field: err.path.join('.') || 'root',
        message: err.message
      }));
      
      return {
        success: false,
        message: 'Validation errors',
        errors
      };
    }
    
    return {
      success: true,
      data: result.data
    };
  } catch (error) {
    return {
      success: false,
      message: 'Invalid JSON in request body',
      errors: [{ field: 'body', message: 'Request body must be valid JSON' }]
    };
  }
}

/**
 * Validate query parameters against a Zod schema
 */
export function validateQueryParams<T>(
  request: NextRequest,
  schema: z.ZodSchema<T>
): ValidateResult<T> {
  try {
    const { searchParams } = new URL(request.url);
    const params: Record<string, string> = {};
    
    searchParams.forEach((value, key) => {
      params[key] = value;
    });
    
    const result = schema.safeParse(params);
    
    if (!result.success) {
      const errors = result.error.errors.map(err => ({
        field: err.path.join('.') || 'root',
        message: err.message
      }));
      
      return {
        success: false,
        message: 'Query parameter validation errors',
        errors
      };
    }
    
    return {
      success: true,
      data: result.data
    };
  } catch (error) {
    return {
      success: false,
      message: 'Error processing query parameters',
      errors: [{ field: 'query', message: 'Invalid query parameters' }]
    };
  }
}

/**
 * Create a validation error response
 */
export function createValidationErrorResponse(errors: Array<{ field: string; message: string }>) {
  return NextResponse.json(
    {
      success: false,
      message: 'Validation errors',
      errors
    },
    { status: 400 }
  );
}

/**
 * Helper function to handle validation in API routes
 */
export async function withValidation<T>(
  request: NextRequest,
  schema: z.ZodSchema<T>,
  handler: (data: T, request: NextRequest) => Promise<NextResponse>
): Promise<NextResponse> {
  const validation = await validateRequestBody(request, schema);
  
  if (!validation.success) {
    return createValidationErrorResponse(validation.errors);
  }
  
  return handler(validation.data, request);
}

/**
 * Sanitize string input (remove HTML tags, trim whitespace)
 */
export function sanitizeString(input: string): string {
  return input
    .replace(/<[^>]*>/g, '') // Remove HTML tags
    .trim() // Remove leading/trailing whitespace
    .substring(0, 1000); // Limit length
}

/**
 * Validate email format
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate phone number format (basic validation)
 */
export function isValidPhoneNumber(phone: string): boolean {
  const phoneRegex = /^\+?[\d\s\-\(\)]{10,}$/;
  return phoneRegex.test(phone);
}

/**
 * Common validation patterns
 */
export const CommonPatterns = {
  // Firebase UID pattern
  firebaseUid: z.string().regex(/^[a-zA-Z0-9]{28}$/, 'Invalid Firebase UID format'),
  
  // FCM Token pattern (simplified)
  fcmToken: z.string().min(140).max(200),
  
  // Phone number with country code
  phoneNumber: z.string().regex(/^\+?[\d\s\-\(\)]{10,}$/, 'Invalid phone number format'),
  
  // Blood type
  bloodType: z.enum(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
  
  // Priority levels
  priority: z.enum(['low', 'normal', 'high', 'critical']),
  
  // Notification type
  notificationType: z.enum(['general', 'blood_request', 'emergency', 'reminder', 'announcement']),
  
  // User role
  userRole: z.enum(['user', 'donor', 'admin', 'hospital'])
};

export default {
  fcmTokenSchema,
  notificationSettingsSchema,
  testNotificationSchema,
  availabilitySchema,
  sendNotificationSchema,
  bulkNotificationSchema,
  bloodRequestSchema,
  validateRequestBody,
  validateQueryParams,
  createValidationErrorResponse,
  withValidation,
  sanitizeString,
  isValidEmail,
  isValidPhoneNumber,
  CommonPatterns
};
