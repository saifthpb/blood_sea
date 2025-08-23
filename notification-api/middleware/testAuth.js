const { logger } = require('../utils/logger');

/**
 * Test authentication middleware for local development
 * This bypasses Firebase authentication for easier testing
 */
const testAuthenticateToken = async (req, res, next) => {
  try {
    // Check if we're in test mode
    if (process.env.NODE_ENV !== 'development' && process.env.ENABLE_TEST_AUTH !== 'true') {
      return res.status(403).json({
        success: false,
        message: 'Test authentication only available in development mode'
      });
    }

    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authorization header missing or invalid format'
      });
    }

    const token = authHeader.split('Bearer ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Token missing'
      });
    }

    // For testing, create a mock user from the token
    // In real app, you'd get this from Firebase Auth
    const testUserId = 'test-user-' + Date.now();
    
    req.user = {
      uid: testUserId,
      email: `test-${Date.now()}@bloodsea.test`,
      emailVerified: true,
      isAdmin: false,
      customClaims: {
        testUser: true,
        createdAt: new Date().toISOString()
      }
    };

    logger.info(`✅ Test user authenticated: ${req.user.uid}`);
    next();

  } catch (error) {
    logger.error('❌ Test authentication error:', error);
    
    return res.status(401).json({
      success: false,
      message: 'Test authentication failed',
      error: error.message
    });
  }
};

/**
 * Middleware that tries real auth first, falls back to test auth
 */
const flexibleAuth = async (req, res, next) => {
  try {
    // Try real Firebase authentication first
    const { authenticateToken } = require('./auth');
    await authenticateToken(req, res, next);
  } catch (error) {
    // If real auth fails and we're in development, try test auth
    if (process.env.NODE_ENV === 'development') {
      logger.warn('⚠️ Real auth failed, trying test auth...');
      await testAuthenticateToken(req, res, next);
    } else {
      throw error;
    }
  }
};

module.exports = {
  testAuthenticateToken,
  flexibleAuth
};
