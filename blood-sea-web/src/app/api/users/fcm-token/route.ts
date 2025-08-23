import { NextRequest, NextResponse } from 'next/server';
import { adminDb } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth-middleware';
import { withErrorHandler } from '@/lib/error-handler';
import { withRateLimit, RateLimitConfigs } from '@/lib/rate-limit';
import { validateRequestBody, fcmTokenSchema } from '@/lib/validation';
import { logger } from '@/lib/logger';

/**
 * @route   POST /api/users/fcm-token
 * @desc    Save or update user's FCM token
 * @access  Private
 */
async function postHandler(request: NextRequest) {
  return requireAuth(request, async (req, user) => {
    // Validate request body
    const validation = await validateRequestBody(req, fcmTokenSchema);
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

    const { fcmToken, platform } = validation.data;
    const userId = user.uid;

    try {
      // Update user document with FCM token
      await adminDb.collection('users').doc(userId).update({
        fcmToken,
        platform: platform || 'unknown',
        tokenUpdatedAt: new Date(),
        lastActive: new Date()
      });

      logger.info(`✅ FCM token updated for user ${userId}`);

      return NextResponse.json({
        success: true,
        message: 'FCM token updated successfully'
      });

    } catch (error: any) {
      logger.error('❌ Error updating FCM token:', error);
      throw error; // Will be handled by error handler
    }
  });
}

/**
 * @route   DELETE /api/users/fcm-token
 * @desc    Remove user's FCM token (logout)
 * @access  Private
 */
async function deleteHandler(request: NextRequest) {
  return requireAuth(request, async (req, user) => {
    const userId = user.uid;

    try {
      // Remove FCM token from user document
      await adminDb.collection('users').doc(userId).update({
        fcmToken: null,
        tokenUpdatedAt: new Date(),
        lastActive: new Date()
      });

      logger.info(`🗑️ FCM token removed for user ${userId}`);

      return NextResponse.json({
        success: true,
        message: 'FCM token removed successfully'
      });

    } catch (error: any) {
      logger.error('❌ Error removing FCM token:', error);
      throw error; // Will be handled by error handler
    }
  });
}

// Apply rate limiting and error handling
export const POST = withRateLimit(
  RateLimitConfigs.general,
  withErrorHandler(postHandler)
);

export const DELETE = withRateLimit(
  RateLimitConfigs.general,
  withErrorHandler(deleteHandler)
);

// Handle OPTIONS for CORS
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}
