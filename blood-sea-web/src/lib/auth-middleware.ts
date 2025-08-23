import { NextRequest, NextResponse } from 'next/server';
import { adminAuth, adminDb } from './firebase-admin';
import { logger } from './logger';
import { DecodedIdToken } from 'firebase-admin/auth';

// Extended user interface with additional properties
export interface AuthenticatedUser {
  uid: string;
  email?: string;
  emailVerified: boolean;
  isAdmin: boolean;
  isDonor?: boolean;
  userData?: any;
  customClaims: DecodedIdToken;
}

// Error response interface
export interface AuthErrorResponse {
  success: false;
  message: string;
  error?: string;
}

/**
 * Extract and verify Firebase ID token from request
 */
export async function authenticateToken(request: NextRequest): Promise<AuthenticatedUser | null> {
  try {
    const authHeader = request.headers.get('authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    const idToken = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    if (!idToken) {
      return null;
    }

    // Verify the ID token
    const decodedToken = await adminAuth.verifyIdToken(idToken);
    
    // Create authenticated user object
    const user: AuthenticatedUser = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified || false,
      isAdmin: decodedToken.admin || false,
      customClaims: decodedToken
    };

    logger.info(`✅ User authenticated: ${decodedToken.uid}`);
    return user;

  } catch (error: any) {
    logger.error('❌ Authentication error:', error);
    return null;
  }
}

/**
 * Middleware to require authentication
 */
export async function requireAuth(
  request: NextRequest,
  handler: (request: NextRequest, user: AuthenticatedUser) => Promise<NextResponse>
): Promise<NextResponse> {
  const user = await authenticateToken(request);
  
  if (!user) {
    return NextResponse.json(
      {
        success: false,
        message: 'Authorization header missing or invalid format'
      },
      { status: 401 }
    );
  }
  
  return handler(request, user);
}

/**
 * Middleware to require admin access
 */
export async function requireAdmin(
  request: NextRequest,
  handler: (request: NextRequest, user: AuthenticatedUser) => Promise<NextResponse>
): Promise<NextResponse> {
  const user = await authenticateToken(request);
  
  if (!user) {
    return NextResponse.json(
      {
        success: false,
        message: 'Authentication required'
      },
      { status: 401 }
    );
  }
  
  if (!user.isAdmin) {
    return NextResponse.json(
      {
        success: false,
        message: 'Admin access required'
      },
      { status: 403 }
    );
  }
  
  return handler(request, user);
}

/**
 * Middleware to require donor access
 */
export async function requireDonor(
  request: NextRequest,
  handler: (request: NextRequest, user: AuthenticatedUser) => Promise<NextResponse>
): Promise<NextResponse> {
  const user = await authenticateToken(request);
  
  if (!user) {
    return NextResponse.json(
      {
        success: false,
        message: 'Authentication required'
      },
      { status: 401 }
    );
  }

  try {
    // Check user's donor status from Firestore
    const userDoc = await adminDb.collection('users').doc(user.uid).get();
    
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
          message: 'Donor access required'
        },
        { status: 403 }
      );
    }

    // Add donor info to user object
    user.isDonor = true;
    user.userData = userData;
    
    return handler(request, user);

  } catch (error: any) {
    logger.error('❌ Error checking donor status:', error);
    return NextResponse.json(
      {
        success: false,
        message: 'Internal server error',
        error: error.message
      },
      { status: 500 }
    );
  }
}

/**
 * Optional authentication middleware (doesn't fail if no token)
 */
export async function optionalAuth(
  request: NextRequest,
  handler: (request: NextRequest, user?: AuthenticatedUser) => Promise<NextResponse>
): Promise<NextResponse> {
  const user = await authenticateToken(request);
  return handler(request, user || undefined);
}

/**
 * Higher-order function to create protected API routes
 */
export function createProtectedRoute(
  authType: 'required' | 'admin' | 'donor' | 'optional',
  handler: (request: NextRequest, user?: AuthenticatedUser) => Promise<NextResponse>
) {
  switch (authType) {
    case 'required':
      return (request: NextRequest) => requireAuth(request, handler as any);
    case 'admin':
      return (request: NextRequest) => requireAdmin(request, handler as any);
    case 'donor':
      return (request: NextRequest) => requireDonor(request, handler as any);
    case 'optional':
      return (request: NextRequest) => optionalAuth(request, handler);
    default:
      throw new Error(`Unknown auth type: ${authType}`);
  }
}

/**
 * Extract user ID from authenticated request
 */
export function getUserId(user: AuthenticatedUser): string {
  return user.uid;
}

/**
 * Check if user has specific custom claim
 */
export function hasCustomClaim(user: AuthenticatedUser, claim: string): boolean {
  return user.customClaims[claim] === true;
}

/**
 * Get user role from custom claims or user data
 */
export function getUserRole(user: AuthenticatedUser): string {
  if (user.isAdmin) return 'admin';
  if (user.isDonor) return 'donor';
  return user.customClaims.role || 'user';
}

/**
 * Middleware to check specific permissions
 */
export async function requirePermission(
  request: NextRequest,
  permission: string,
  handler: (request: NextRequest, user: AuthenticatedUser) => Promise<NextResponse>
): Promise<NextResponse> {
  const user = await authenticateToken(request);
  
  if (!user) {
    return NextResponse.json(
      {
        success: false,
        message: 'Authentication required'
      },
      { status: 401 }
    );
  }
  
  // Admin has all permissions
  if (user.isAdmin) {
    return handler(request, user);
  }
  
  // Check if user has the specific permission
  if (!hasCustomClaim(user, permission)) {
    return NextResponse.json(
      {
        success: false,
        message: `Permission '${permission}' required`
      },
      { status: 403 }
    );
  }
  
  return handler(request, user);
}

/**
 * Create authentication error response
 */
export function createAuthErrorResponse(message: string, statusCode: number = 401): NextResponse {
  return NextResponse.json(
    {
      success: false,
      message
    },
    { status: statusCode }
  );
}

/**
 * Validate Firebase ID token format (basic validation)
 */
export function isValidIdTokenFormat(token: string): boolean {
  // Basic format check - Firebase ID tokens are JWT tokens
  const parts = token.split('.');
  return parts.length === 3 && parts.every(part => part.length > 0);
}

/**
 * Get authentication error message based on Firebase error code
 */
export function getAuthErrorMessage(errorCode: string): { message: string; statusCode: number } {
  switch (errorCode) {
    case 'auth/id-token-expired':
      return { message: 'Token has expired', statusCode: 401 };
    case 'auth/id-token-revoked':
      return { message: 'Token has been revoked', statusCode: 401 };
    case 'auth/invalid-id-token':
      return { message: 'Invalid token format', statusCode: 401 };
    case 'auth/project-not-found':
      return { message: 'Firebase project not found', statusCode: 500 };
    case 'auth/insufficient-permission':
      return { message: 'Insufficient permissions', statusCode: 403 };
    default:
      return { message: 'Invalid or expired token', statusCode: 401 };
  }
}

/**
 * Middleware with detailed error handling
 */
export async function authenticateWithErrorHandling(
  request: NextRequest,
  handler: (request: NextRequest, user: AuthenticatedUser) => Promise<NextResponse>
): Promise<NextResponse> {
  try {
    const authHeader = request.headers.get('authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return createAuthErrorResponse('Authorization header missing or invalid format');
    }

    const idToken = authHeader.substring(7);
    
    if (!idToken) {
      return createAuthErrorResponse('ID token missing');
    }

    if (!isValidIdTokenFormat(idToken)) {
      return createAuthErrorResponse('Invalid token format');
    }

    // Verify the ID token
    const decodedToken = await adminAuth.verifyIdToken(idToken);
    
    const user: AuthenticatedUser = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified || false,
      isAdmin: decodedToken.admin || false,
      customClaims: decodedToken
    };

    logger.info(`✅ User authenticated: ${decodedToken.uid}`);
    return handler(request, user);

  } catch (error: any) {
    logger.error('❌ Authentication error:', error);
    
    const { message, statusCode } = getAuthErrorMessage(error.code);
    return NextResponse.json(
      {
        success: false,
        message,
        error: error.code
      },
      { status: statusCode }
    );
  }
}

export default {
  authenticateToken,
  requireAuth,
  requireAdmin,
  requireDonor,
  optionalAuth,
  createProtectedRoute,
  requirePermission,
  getUserId,
  hasCustomClaim,
  getUserRole,
  createAuthErrorResponse,
  isValidIdTokenFormat,
  getAuthErrorMessage,
  authenticateWithErrorHandling
};
