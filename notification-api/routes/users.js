const express = require('express');
const { body, validationResult } = require('express-validator');
const { authenticateToken } = require('../middleware/auth');
const { logger } = require('../utils/logger');

const router = express.Router();

// Lazy initialization to avoid initialization order issues
const getFirestore = () => {
  const { getFirestore: getFirebaseFirestore } = require('../config/firebase');
  return getFirebaseFirestore();
};

/**
 * @route   POST /api/users/fcm-token
 * @desc    Save or update user's FCM token
 * @access  Private
 */
router.post('/fcm-token', 
  authenticateToken,
  [
    body('fcmToken').notEmpty().withMessage('FCM token is required'),
    body('platform').optional().isIn(['android', 'ios', 'web']).withMessage('Invalid platform')
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation errors',
          errors: errors.array()
        });
      }

      const { fcmToken, platform } = req.body;
      const userId = req.user.uid;
      const db = getFirestore();

      // Update user document with FCM token
      await db.collection('users').doc(userId).update({
        fcmToken,
        platform: platform || 'unknown',
        tokenUpdatedAt: new Date(),
        lastActive: new Date()
      });

      logger.info(`✅ FCM token updated for user ${userId}`);

      res.status(200).json({
        success: true,
        message: 'FCM token updated successfully'
      });

    } catch (error) {
      logger.error('❌ Error updating FCM token:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/users/fcm-token
 * @desc    Remove user's FCM token (logout)
 * @access  Private
 */
router.delete('/fcm-token', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.uid;

    // Remove FCM token from user document
    await db.collection('users').doc(userId).update({
      fcmToken: null,
      tokenUpdatedAt: new Date(),
      lastActive: new Date()
    });

    logger.info(`🗑️ FCM token removed for user ${userId}`);

    res.status(200).json({
      success: true,
      message: 'FCM token removed successfully'
    });

  } catch (error) {
    logger.error('❌ Error removing FCM token:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   GET /api/users/notification-settings
 * @desc    Get user's notification preferences
 * @access  Private
 */
router.get('/notification-settings', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.uid;

    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();
    const notificationSettings = userData.notificationSettings || {
      bloodRequests: true,
      emergencyRequests: true,
      generalAnnouncements: true,
      donationReminders: true,
      soundEnabled: true,
      vibrationEnabled: true
    };

    res.status(200).json({
      success: true,
      settings: notificationSettings
    });

  } catch (error) {
    logger.error('❌ Error fetching notification settings:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   PUT /api/users/notification-settings
 * @desc    Update user's notification preferences
 * @access  Private
 */
router.put('/notification-settings',
  authenticateToken,
  [
    body('bloodRequests').optional().isBoolean(),
    body('emergencyRequests').optional().isBoolean(),
    body('generalAnnouncements').optional().isBoolean(),
    body('donationReminders').optional().isBoolean(),
    body('soundEnabled').optional().isBoolean(),
    body('vibrationEnabled').optional().isBoolean()
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation errors',
          errors: errors.array()
        });
      }

      const userId = req.user.uid;
      const settings = req.body;

      // Update notification settings
      await db.collection('users').doc(userId).update({
        notificationSettings: settings,
        updatedAt: new Date()
      });

      logger.info(`⚙️ Notification settings updated for user ${userId}`);

      res.status(200).json({
        success: true,
        message: 'Notification settings updated successfully',
        settings
      });

    } catch (error) {
      logger.error('❌ Error updating notification settings:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  }
);

/**
 * @route   POST /api/users/test-notification
 * @desc    Send a test notification to the user
 * @access  Private
 */
router.post('/test-notification', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const { NotificationService } = require('../services/notificationService');

    const result = await NotificationService.sendNotification({
      userId,
      title: '🧪 Test Notification',
      body: 'This is a test notification from Blood Sea API',
      data: {
        type: 'test',
        timestamp: new Date().toISOString()
      },
      priority: 'normal'
    });

    if (result.success) {
      logger.info(`🧪 Test notification sent to user ${userId}`);
      res.status(200).json({
        success: true,
        message: 'Test notification sent successfully',
        notificationId: result.notificationId
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to send test notification',
        error: result.error
      });
    }

  } catch (error) {
    logger.error('❌ Error sending test notification:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   GET /api/users/profile
 * @desc    Get user profile information
 * @access  Private
 */
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.uid;

    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();
    
    // Remove sensitive information
    delete userData.fcmToken;
    delete userData.tokenUpdatedAt;

    res.status(200).json({
      success: true,
      user: {
        uid: userId,
        ...userData
      }
    });

  } catch (error) {
    logger.error('❌ Error fetching user profile:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   PUT /api/users/availability
 * @desc    Update donor availability status
 * @access  Private
 */
router.put('/availability',
  authenticateToken,
  [
    body('isAvailable').isBoolean().withMessage('Availability status must be boolean')
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation errors',
          errors: errors.array()
        });
      }

      const userId = req.user.uid;
      const { isAvailable } = req.body;

      // Check if user is a donor
      const userDoc = await db.collection('users').doc(userId).get();
      
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
          message: 'Only donors can update availability status'
        });
      }

      // Update availability
      await db.collection('users').doc(userId).update({
        isAvailable,
        availabilityUpdatedAt: new Date(),
        updatedAt: new Date()
      });

      logger.info(`📍 Availability updated for donor ${userId}: ${isAvailable}`);

      res.status(200).json({
        success: true,
        message: 'Availability status updated successfully',
        isAvailable
      });

    } catch (error) {
      logger.error('❌ Error updating availability:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  }
);

module.exports = router;
