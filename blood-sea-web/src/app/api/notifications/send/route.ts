import { NextRequest, NextResponse } from 'next/server';
import { notificationService } from '@/lib/notification-service';
import { requireAuth } from '@/lib/auth-middleware';
import { withErrorHandler } from '@/lib/error-handler';
import { withRateLimit, RateLimitConfigs } from '@/lib/rate-limit';
import { validateRequestBody, sendNotificationSchema } from '@/lib/validation';

async function postHandler(request: NextRequest) {
  return requireAuth(request, async (req, user) => {
    // Validate request body
    const validation = await validateRequestBody(req, sendNotificationSchema);
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

    const { userId, fcmToken, title, body, data, priority, type } = validation.data;

    // Send notification
    const result = await notificationService.sendToUser({
      userId,
      fcmToken,
      title,
      body,
      data: data || {},
      priority: priority || 'normal',
      type: type || 'general',
    });

    if (result.success) {
      return NextResponse.json({
        success: true,
        message: 'Notification sent successfully',
        messageId: result.messageId,
      });
    } else {
      return NextResponse.json(
        {
          success: false,
          message: 'Failed to send notification',
          error: result.error,
        },
        { status: 500 }
      );
    }
  });
}

// Apply rate limiting and error handling
export const POST = withRateLimit(
  RateLimitConfigs.notifications,
  withErrorHandler(postHandler)
);

// Handle OPTIONS for CORS
export async function OPTIONS(request: NextRequest) {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}
