import { NextRequest, NextResponse } from 'next/server';
import { requireAuth } from '@/lib/auth-middleware';
import { withErrorHandler } from '@/lib/error-handler';
import { withRateLimit, RateLimitConfigs } from '@/lib/rate-limit';
import { validateRequestBody, testNotificationSchema } from '@/lib/validation';
import { notificationService } from '@/lib/notification-service';
import { logger } from '@/lib/logger';

/**
 * @route   POST /api/users/test-notification
 * @desc    Send a test notification to the user
 * @access  Private
 */
async function postHandler(request: NextRequest) {
  return requireAuth(request, async (req, user) => {
    // Validate request body (optional message)
    const validation = await validateRequestBody(req, testNotificationSchema);
    if (!validation.success) {
      return NextResponse.json(
        {
          success: false,
          message: 'Validation errors',
          errors: validation.errors
        },
        { status: 400 }
      );
    }

    const userId = user.uid;
    const { message: customMessage } = validation.data;

    try {
      const result = await notificationService.sendToUser({
        userId,
        title: '🧪 Test Notification',
        body: customMessage || 'This is a test notification from Blood Sea API',
        data: {
          type: 'test',
          timestamp: new Date().toISOString()
        },
        priority: 'normal'
      });

      if (result.success) {
        logger.info(`🧪 Test notification sent to user ${userId}`);
        
        return NextResponse.json({
          success: true,
          message: 'Test notification sent successfully',
          messageId: result.messageId
        });
      } else {
        return NextResponse.json(
          {
            success: false,
            message: 'Failed to send test notification',
            error: result.error
          },
          { status: 500 }
        );
      }

    } catch (error: any) {
      logger.error('❌ Error sending test notification:', error);
      throw error; // Will be handled by error handler
    }
  });
}

// Apply rate limiting and error handling
// Use stricter rate limiting for test notifications
export const POST = withRateLimit(
  {
    ...RateLimitConfigs.notifications,
    maxRequests: 5, // Only 5 test notifications per minute
    message: 'Too many test notification requests, please try again later.'
  },
  withErrorHandler(postHandler)
);

// Handle OPTIONS for CORS
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}
