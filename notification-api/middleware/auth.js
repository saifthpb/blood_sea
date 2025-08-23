const { logger } = require('../utils/logger');

// Initialize auth lazily to avoid initialization order issues
let auth = null;

const getAuth = () => {
  if (!auth) {
    try {
      const { getAuth: getFirebaseAuth } = require('../config/firebase');
      auth = getFirebaseAuth();
    } catch (error) {
      logger.error('Error getting Firebase Auth:', error);
      throw error;
    }
  }
  return auth;
};

/**
 * Middleware to authenticate Firebase ID tokens
 */
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authorization header missing or invalid format'
      });
    }

    const idToken = authHeader.split('Bearer ')[1];
    
    if (!idToken) {
      return res.status(401).json({
        success: false,
        message: 'ID token missing'
      });
    }

    // Verify the ID token
    const firebaseAuth = getAuth();
    const decodedToken = await firebaseAuth.verifyIdToken(idToken);
    
    // Add user info to request object
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified,
      isAdmin: decodedToken.admin || false,
      customClaims: decodedToken
    };

    logger.info(`✅ User authenticated: ${decodedToken.uid}`);
    next();

  } catch (error) {
    logger.error('❌ Authentication error:', error);
    
    let message = 'Invalid or expired token';
    let statusCode = 401;

    if (error.code === 'auth/id-token-expired') {
      message = 'Token has expired';
    } else if (error.code === 'auth/id-token-revoked') {
      message = 'Token has been revoked';
    } else if (error.code === 'auth/invalid-id-token') {
      message = 'Invalid token format';
    }

    return res.status(statusCode).json({
      success: false,
      message,
      error: error.code
    });
  }
};

/**
 * Middleware to check if user is admin
 */
const requireAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
  }

  if (!req.user.isAdmin) {
    return res.status(403).json({
      success: false,
      message: 'Admin access required'
    });
  }

  next();
};

/**
 * Middleware to check if user is donor
 */
const requireDonor = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    // Check user's donor status from Firestore
    const { getFirestore } = require('../config/firebase');
    const db = getFirestore();
    
    const userDoc = await db.collection('users').doc(req.user.uid).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();
    
    if (!userData.isDonor) {
      return res.status(403).json({
        success: false,
        message: 'Donor access required'
      });
    }

    req.user.isDonor = true;
    req.user.userData = userData;
    next();

  } catch (error) {
    logger.error('❌ Error checking donor status:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

/**
 * Optional authentication middleware (doesn't fail if no token)
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const idToken = authHeader.split('Bearer ')[1];
    
    if (!idToken) {
      return next();
    }

    const firebaseAuth = getAuth();
    const decodedToken = await firebaseAuth.verifyIdToken(idToken);
    
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified,
      isAdmin: decodedToken.admin || false,
      customClaims: decodedToken
    };

    next();

  } catch (error) {
    // Don't fail, just continue without user
    logger.warn('⚠️ Optional auth failed:', error.message);
    next();
  }
};

module.exports = {
  authenticateToken,
  requireAdmin,
  requireDonor,
  optionalAuth
};
