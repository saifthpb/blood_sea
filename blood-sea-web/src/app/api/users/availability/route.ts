import { NextRequest, NextResponse } from 'next/server';
import { adminDb } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth-middleware';
import { withErrorHandler } from '@/lib/error-handler';
import { withRateLimit, RateLimitConfigs } from '@/lib/rate-limit';
import { validateRequestBody, availabilitySchema } from '@/lib/validation';
import { logger } from '@/lib/logger';

/**
 * @route   PUT /api/users/availability
 * @desc    Update donor availability status
 * @access  Private (Donor only)
 */
async function putHandler(request: NextRequest) {
  return requireAuth(request, async (req, user) => {
    // Validate request body
    const validation = await validateRequestBody(req, availabilitySchema);
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
    const { isAvailable } = validation.data;

    try {
      // Check if user is a donor
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
      
      if (!userData?.isDonor) {
        return NextResponse.json(
          {
            success: false,
            message: 'Only donors can update availability status'
          },
          { status: 403 }
        );
      }

      // Update availability
      await adminDb.collection('users').doc(userId).update({
        isAvailable,
        availabilityUpdatedAt: new Date(),
        updatedAt: new Date()
      });

      logger.info(`📍 Availability updated for donor ${userId}: ${isAvailable}`);

      return NextResponse.json({
        success: true,
        message: 'Availability status updated successfully',
        isAvailable
      });

    } catch (error: any) {
      logger.error('❌ Error updating availability:', error);
      throw error; // Will be handled by error handler
    }
  });
}

// Apply rate limiting and error handling
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
      'Access-Control-Allow-Methods': 'PUT, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}
