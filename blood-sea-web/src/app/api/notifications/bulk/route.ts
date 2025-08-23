import { NextRequest, NextResponse } from 'next/server';
import { notificationService } from '@/lib/notification-service';
import { adminAuth } from '@/lib/firebase-admin';

// Authentication middleware
async function authenticateRequest(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    const token = authHeader.substring(7);
    const decodedToken = await adminAuth.verifyIdToken(token);
    return decodedToken;
  } catch (error) {
    console.error('Authentication error:', error);
    return null;
  }
}

export async function POST(request: NextRequest) {
  try {
    // Authenticate request
    const user = await authenticateRequest(request);
    if (!user) {
      return NextResponse.json(
        { 
          success: false, 
          message: 'Authorization header missing or invalid format' 
        },
        { status: 401 }
      );
    }

    const body = await request.json();
    
    // Validate required fields
    if (!body.title || !body.body) {
      return NextResponse.json(
        { 
          success: false, 
          message: 'Title and body are required' 
        },
        { status: 400 }
      );
    }

    if (!body.userIds && !body.fcmTokens) {
      return NextResponse.json(
        { 
          success: false, 
          message: 'Either userIds or fcmTokens array is required' 
        },
        { status: 400 }
      );
    }

    // Validate arrays
    const userIds = body.userIds || [];
    const fcmTokens = body.fcmTokens || [];
    
    if (userIds.length === 0 && fcmTokens.length === 0) {
      return NextResponse.json(
        { 
          success: false, 
          message: 'At least one user ID or FCM token is required' 
        },
        { status: 400 }
      );
    }

    // Send bulk notification
    const result = await notificationService.sendToMultipleUsers({
      userIds: userIds,
      fcmTokens: fcmTokens,
      title: body.title,
      body: body.body,
      data: body.data || {},
      priority: body.priority || 'normal',
      type: body.type || 'general',
    });

    return NextResponse.json({
      success: result.success,
      message: `Notifications processed: ${result.successCount} sent, ${result.failureCount} failed`,
      successCount: result.successCount,
      failureCount: result.failureCount,
      details: result.responses,
    });
  } catch (error: any) {
    console.error('Error in bulk notification API:', error);
    return NextResponse.json(
      {
        success: false,
        message: 'Internal server error',
        error: error.message,
      },
      { status: 500 }
    );
  }
}

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
