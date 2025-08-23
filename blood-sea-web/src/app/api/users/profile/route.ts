import { NextRequest, NextResponse } from 'next/server';
import { adminDb } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth-middleware';
import { withErrorHandler } from '@/lib/error-handler';
import { withRateLimit, RateLimitConfigs } from '@/lib/rate-limit';
import { logger } from '@/lib/logger';

/**
 * @route   GET /api/users/profile
 * @desc    Get user profile information
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
      
      // Remove sensitive information
      const sanitizedUserData = { ...userData };
      delete sanitizedUserData.fcmToken;
      delete sanitizedUserData.tokenUpdatedAt;
      
      // Also remove any other sensitive fields
      const sensitiveFields = ['password', 'privateKey', 'secret'];
      sensitiveFields.forEach(field => {
        delete sanitizedUserData[field];
      });

      return NextResponse.json({
        success: true,
        user: {
          uid: userId,
          email: user.email,
          emailVerified: user.emailVerified,
          ...sanitizedUserData
        }
      });

    } catch (error: any) {
      logger.error('❌ Error fetching user profile:', error);
      throw error; // Will be handled by error handler
    }
  });
}

// Apply rate limiting and error handling
export const GET = withRateLimit(
  RateLimitConfigs.general,
  withErrorHandler(getHandler)
);

// Handle OPTIONS for CORS
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}
