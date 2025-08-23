const express = require('express');
const { body, validationResult } = require('express-validator');
const { authenticateToken } = require('../middleware/auth');
const { logger } = require('../utils/logger');
const { NotificationService } = require('../services/notificationService');

const router = express.Router();

// Lazy initialization to avoid initialization order issues
const getFirestore = () => {
  const { getFirestore: getFirebaseFirestore } = require('../config/firebase');
  return getFirebaseFirestore();
};

const getMessaging = () => {
  const { getMessaging: getFirebaseMessaging } = require('../config/firebase');
  return getFirebaseMessaging();
};

// Validation rules
const sendNotificationValidation = [
  body('userId').notEmpty().withMessage('User ID is required'),
  body('title').notEmpty().withMessage('Title is required'),
  body('body').notEmpty().withMessage('Body is required'),
  body('priority').optional().isIn(['low', 'normal', 'high', 'critical']).withMessage('Invalid priority'),
];

const bloodRequestValidation = [
  body('donorId').notEmpty().withMessage('Donor ID is required'),
  body('requesterId').notEmpty().withMessage('Requester ID is required'),
  body('requesterName').notEmpty().withMessage('Requester name is required'),
  body('bloodType').notEmpty().withMessage('Blood type is required'),
  body('location').notEmpty().withMessage('Location is required'),
  body('urgency').isIn(['normal', 'urgent', 'emergency']).withMessage('Invalid urgency level'),
  body('requiredDate').isISO8601().withMessage('Invalid date format'),
];

/**
 * @route   POST /api/notifications/send
 * @desc    Send a general notification to a user
 * @access  Private
 */
router.post('/send', authenticateToken, sendNotificationValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation errors',
        errors: errors.array()
      });
    }

    const { userId, title, body, data = {}, priority = 'normal' } = req.body;

    const result = await NotificationService.sendNotification({
      userId,
      title,
      body,
      data: {
        ...data,
        senderId: req.user.uid,
        timestamp: new Date().toISOString()
      },
      priority
    });

    if (result.success) {
      logger.info(`✅ Notification sent successfully to user ${userId}`);
      res.status(200).json({
        success: true,
        message: 'Notification sent successfully',
        notificationId: result.notificationId
      });
    } else {
      logger.error(`❌ Failed to send notification to user ${userId}: ${result.error}`);
      res.status(500).json({
        success: false,
        message: 'Failed to send notification',
        error: result.error
      });
    }
  } catch (error) {
    logger.error('❌ Error in send notification endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   POST /api/notifications/blood-request
 * @desc    Send a blood request notification
 * @access  Private
 */
router.post('/blood-request', authenticateToken, bloodRequestValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation errors',
        errors: errors.array()
      });
    }

    const {
      donorId,
      requesterId,
      requesterName,
      requesterPhone,
      bloodType,
      location,
      urgency,
      requiredDate,
      additionalMessage
    } = req.body;

    const result = await NotificationService.sendBloodRequestNotification({
      donorId,
      requesterId,
      requesterName,
      requesterPhone,
      bloodType,
      location,
      urgency,
      requiredDate: new Date(requiredDate),
      additionalMessage
    });

    if (result.success) {
      logger.info(`🩸 Blood request notification sent to donor ${donorId} from ${requesterName}`);
      res.status(200).json({
        success: true,
        message: 'Blood request notification sent successfully',
        notificationId: result.notificationId,
        requestId: result.requestId
      });
    } else {
      logger.error(`❌ Failed to send blood request notification: ${result.error}`);
      res.status(500).json({
        success: false,
        message: 'Failed to send blood request notification',
        error: result.error
      });
    }
  } catch (error) {
    logger.error('❌ Error in blood request notification endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   POST /api/notifications/bulk-send
 * @desc    Send notifications to multiple users
 * @access  Private
 */
router.post('/bulk-send', authenticateToken, async (req, res) => {
  try {
    const { userIds, title, body, data = {}, priority = 'normal' } = req.body;

    if (!Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'User IDs array is required and cannot be empty'
      });
    }

    if (userIds.length > 1000) {
      return res.status(400).json({
        success: false,
        message: 'Cannot send to more than 1000 users at once'
      });
    }

    const results = await NotificationService.sendBulkNotifications({
      userIds,
      title,
      body,
      data: {
        ...data,
        senderId: req.user.uid,
        timestamp: new Date().toISOString()
      },
      priority
    });

    logger.info(`📢 Bulk notification sent to ${userIds.length} users`);
    res.status(200).json({
      success: true,
      message: 'Bulk notifications processed',
      results: {
        total: userIds.length,
        successful: results.successful,
        failed: results.failed,
        details: results.details
      }
    });
  } catch (error) {
    logger.error('❌ Error in bulk send notification endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   GET /api/notifications/user/:userId
 * @desc    Get notifications for a specific user
 * @access  Private
 */
router.get('/user/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 50, offset = 0, unreadOnly = false } = req.query;

    // Check if user is requesting their own notifications or is admin
    if (req.user.uid !== userId && !req.user.isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    const db = getFirestore();
    let query = db.collection('notifications')
      .where('recipientId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(parseInt(limit))
      .offset(parseInt(offset));

    if (unreadOnly === 'true') {
      query = query.where('isRead', '==', false);
    }

    const snapshot = await query.get();
    const notifications = [];

    snapshot.forEach(doc => {
      notifications.push({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate?.()?.toISOString()
      });
    });

    res.status(200).json({
      success: true,
      notifications,
      count: notifications.length,
      hasMore: notifications.length === parseInt(limit)
    });
  } catch (error) {
    logger.error('❌ Error fetching user notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   PUT /api/notifications/:notificationId/read
 * @desc    Mark notification as read
 * @access  Private
 */
router.put('/:notificationId/read', authenticateToken, async (req, res) => {
  try {
    const { notificationId } = req.params;
    const db = getFirestore();

    const notificationRef = db.collection('notifications').doc(notificationId);
    const notificationDoc = await notificationRef.get();

    if (!notificationDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    const notification = notificationDoc.data();

    // Check if user owns this notification
    if (notification.recipientId !== req.user.uid) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    await notificationRef.update({
      isRead: true,
      readAt: new Date(),
      updatedAt: new Date()
    });

    res.status(200).json({
      success: true,
      message: 'Notification marked as read'
    });
  } catch (error) {
    logger.error('❌ Error marking notification as read:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   DELETE /api/notifications/:notificationId
 * @desc    Delete a notification
 * @access  Private
 */
router.delete('/:notificationId', authenticateToken, async (req, res) => {
  try {
    const { notificationId } = req.params;
    const db = getFirestore();

    const notificationRef = db.collection('notifications').doc(notificationId);
    const notificationDoc = await notificationRef.get();

    if (!notificationDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    const notification = notificationDoc.data();

    // Check if user owns this notification or is admin
    if (notification.recipientId !== req.user.uid && !req.user.isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    await notificationRef.delete();

    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully'
    });
  } catch (error) {
    logger.error('❌ Error deleting notification:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route   GET /api/notifications/stats/:userId
 * @desc    Get notification statistics for a user
 * @access  Private
 */
router.get('/stats/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;

    // Check if user is requesting their own stats or is admin
    if (req.user.uid !== userId && !req.user.isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    const db = getFirestore();
    const [totalSnapshot, unreadSnapshot] = await Promise.all([
      db.collection('notifications').where('recipientId', '==', userId).get(),
      db.collection('notifications')
        .where('recipientId', '==', userId)
        .where('isRead', '==', false)
        .get()
    ]);

    const stats = {
      total: totalSnapshot.size,
      unread: unreadSnapshot.size,
      read: totalSnapshot.size - unreadSnapshot.size
    };

    res.status(200).json({
      success: true,
      stats
    });
  } catch (error) {
    logger.error('❌ Error fetching notification stats:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

module.exports = router;
