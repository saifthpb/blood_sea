import { NextRequest, NextResponse } from 'next/server';
import { adminDb } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth-middleware';
import { withErrorHandler } from '@/lib/error-handler';
import { withRateLimit, RateLimitConfigs } from '@/lib/rate-limit';
import { validateRequestBody, notificationSettingsSchema } from '@/lib/validation';
import { logger } from '@/lib/logger';

/**
 * @route   GET /api/users/notification-settings
 * @desc    Get user's notification preferences
 * @access  Private
 */
async function getHandler(request: NextRequest) {
  return requireAuth(request, async (req, user) => {
    const userId = user.uid;

    try {
      const userDoc = await adminDb.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return NextResponse.json(
          {
            success: false,
            message: 'User not found'
          },
          { status: 404 }
        );
      }

      const userData = userDoc.data();
      const notificationSettings = userData?.notificationSettings || {
        bloodRequests: true,
        emergencyRequests: true,
        generalAnnouncements: true,
        donationReminders: true,
        soundEnabled: true,
        vibrationEnabled: true
      };

      return NextResponse.json({
        success: true,
        settings: notificationSettings
      });

    } catch (error: any) {
      logger.error('❌ Error fetching notification settings:', error);
      throw error; // Will be handled by error handler
    }
  });
}

/**
 * @route   PUT /api/users/notification-settings
 * @desc    Update user's notification preferences
 * @access  Private
 */
async function putHandler(request: NextRequest) {
  return requireAuth(request, async (req, user) => {
    // Validate request body
    const validation = await validateRequestBody(req, notificationSettingsSchema);
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
    const settings = validation.data;

    try {
      // Update notification settings
      await adminDb.collection('users').doc(userId).update({
        notificationSettings: settings,
        updatedAt: new Date()
      });

      logger.info(`⚙️ Notification settings updated for user ${userId}`);

      return NextResponse.json({
        success: true,
        message: 'Notification settings updated successfully',
        settings
      });

    } catch (error: any) {
      logger.error('❌ Error updating notification settings:', error);
      throw error; // Will be handled by error handler
    }
  });
}

// Apply rate limiting and error handling
export const GET = withRateLimit(
  RateLimitConfigs.general,
  withErrorHandler(getHandler)
);

export const PUT = withRateLimit(
  RateLimitConfigs.general,
  withErrorHandler(putHandler)
);

// Handle OPTIONS for CORS
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}
