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
    const requiredFields = ['donorId', 'requesterId', 'bloodType', 'hospital', 'urgency'];
    const missingFields = requiredFields.filter(field => !body[field]);
    
    if (missingFields.length > 0) {
      return NextResponse.json(
        { 
          success: false, 
          message: `Missing required fields: ${missingFields.join(', ')}` 
        },
        { status: 400 }
      );
    }

    // Validate urgency level
    const validUrgencyLevels = ['low', 'normal', 'high', 'critical'];
    if (!validUrgencyLevels.includes(body.urgency)) {
      return NextResponse.json(
        { 
          success: false, 
          message: 'Invalid urgency level. Must be one of: low, normal, high, critical' 
        },
        { status: 400 }
      );
    }

    // Send blood request notification
    const result = await notificationService.sendBloodRequestNotification({
      donorId: body.donorId,
      requesterId: body.requesterId,
      bloodType: body.bloodType,
      hospital: body.hospital,
      urgency: body.urgency,
      location: body.location,
      contactInfo: body.contactInfo,
    });

    if (result.success) {
      return NextResponse.json({
        success: true,
        message: `Blood request notification sent to ${result.notifiedDonors} eligible donors`,
        notifiedDonors: result.notifiedDonors,
      });
    } else {
      return NextResponse.json(
        {
          success: false,
          message: 'Failed to send blood request notification',
          error: result.error,
          notifiedDonors: result.notifiedDonors,
        },
        { status: 500 }
      );
    }
  } catch (error: any) {
    console.error('Error in blood request notification API:', error);
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
