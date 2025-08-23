const { logger } = require('../utils/logger');

// Lazy initialization to avoid initialization order issues
let db = null;
let messaging = null;

const getFirestore = () => {
  if (!db) {
    const { getFirestore: getFirebaseFirestore } = require('../config/firebase');
    db = getFirebaseFirestore();
  }
  return db;
};

const getMessaging = () => {
  if (!messaging) {
    const { getMessaging: getFirebaseMessaging } = require('../config/firebase');
    messaging = getFirebaseMessaging();
  }
  return messaging;
};

class NotificationService {
  /**
   * Send a notification to a single user
   */
  static async sendNotification({ userId, title, body, data = {}, priority = 'normal' }) {
    try {
      const db = getFirestore();
      const messaging = getMessaging();
      
      // Get user's FCM token
      const userDoc = await db.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return { success: false, error: 'User not found' };
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        return { success: false, error: 'User FCM token not found' };
      }

      // Create notification document
      const notificationData = {
        recipientId: userId,
        title,
        body,
        data,
        priority,
        isRead: false,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      // Save to Firestore
      const notificationRef = await db.collection('notifications').add(notificationData);

      // Prepare FCM message
      const message = {
        token: fcmToken,
        notification: {
          title,
          body
        },
        data: {
          ...data,
          notificationId: notificationRef.id,
          priority
        },
        android: {
          priority: this._getAndroidPriority(priority),
          notification: {
            channelId: this._getChannelId(data.type),
            priority: this._getAndroidNotificationPriority(priority),
            defaultSound: true,
            defaultVibrateTimings: true
          }
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title,
                body
              },
              badge: await this._getBadgeCount(userId),
              sound: 'default',
              'content-available': 1,
              'interruption-level': this._getIOSInterruptionLevel(priority)
            }
          }
        }
      };

      // Send FCM message
      const response = await messaging.send(message);
      
      logger.info(`✅ Notification sent successfully: ${response}`);
      
      return {
        success: true,
        notificationId: notificationRef.id,
        fcmResponse: response
      };

    } catch (error) {
      logger.error('❌ Error sending notification:', error);
      
      // Handle specific FCM errors
      if (error.code === 'messaging/registration-token-not-registered') {
        // Token is invalid, remove it from user document
        await this._removeInvalidToken(userId);
        return { success: false, error: 'Invalid FCM token, token removed' };
      }
      
      return { success: false, error: error.message };
    }
  }

  /**
   * Send blood request notification with enhanced features
   */
  static async sendBloodRequestNotification({
    donorId,
    requesterId,
    requesterName,
    requesterPhone,
    bloodType,
    location,
    urgency,
    requiredDate,
    additionalMessage
  }) {
    try {
      const db = getFirestore();
      
      // Create blood request document
      const requestData = {
        donorId,
        requesterId,
        requesterName,
        requesterPhone,
        bloodType,
        location,
        urgency,
        requiredDate,
        additionalMessage,
        status: 'pending',
        createdAt: new Date(),
        updatedAt: new Date()
      };

      const requestRef = await db.collection('blood_requests').add(requestData);

      // Determine notification type and priority
      const isEmergency = urgency.toLowerCase() === 'emergency';
      const notificationType = isEmergency ? 'emergencyRequest' : 'bloodRequest';
      const priority = isEmergency ? 'critical' : 'high';

      // Create notification title and body
      const title = isEmergency 
        ? `🚨 EMERGENCY: ${bloodType} Blood Needed`
        : `🩸 Blood Request: ${bloodType}`;
      
      const body = `${requesterName} needs ${bloodType} blood at ${location} on ${this._formatDate(requiredDate)}`;

      // Send notification
      const notificationResult = await this.sendNotification({
        userId: donorId,
        title,
        body,
        data: {
          type: notificationType,
          requestId: requestRef.id,
          requesterId,
          requesterName,
          requesterPhone,
          bloodType,
          location,
          urgency,
          requiredDate: requiredDate.toISOString(),
          additionalMessage
        },
        priority
      });

      if (notificationResult.success) {
        // Update request with notification ID
        await requestRef.update({
          notificationId: notificationResult.notificationId
        });

        // Schedule reminder notifications for urgent/emergency requests
        if (urgency.toLowerCase() !== 'normal') {
          await this._scheduleReminderNotifications(requestRef.id, donorId, urgency);
        }

        return {
          success: true,
          notificationId: notificationResult.notificationId,
          requestId: requestRef.id
        };
      } else {
        return notificationResult;
      }

    } catch (error) {
      logger.error('❌ Error sending blood request notification:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send bulk notifications to multiple users
   */
  static async sendBulkNotifications({ userIds, title, body, data = {}, priority = 'normal' }) {
    const results = {
      successful: 0,
      failed: 0,
      details: []
    };

    // Process in batches of 500 (FCM limit)
    const batchSize = 500;
    const batches = [];
    
    for (let i = 0; i < userIds.length; i += batchSize) {
      batches.push(userIds.slice(i, i + batchSize));
    }

    for (const batch of batches) {
      try {
        // Get FCM tokens for batch
        const tokens = await this._getTokensForUsers(batch);
        
        if (tokens.length === 0) {
          results.failed += batch.length;
          continue;
        }

        // Create multicast message
        const message = {
          tokens,
          notification: { title, body },
          data: {
            ...data,
            priority,
            timestamp: new Date().toISOString()
          },
          android: {
            priority: this._getAndroidPriority(priority),
            notification: {
              channelId: this._getChannelId(data.type),
              priority: this._getAndroidNotificationPriority(priority)
            }
          },
          apns: {
            payload: {
              aps: {
                alert: { title, body },
                sound: 'default',
                'content-available': 1
              }
            }
          }
        };

        // Send multicast message
        const response = await messaging.sendMulticast(message);
        
        results.successful += response.successCount;
        results.failed += response.failureCount;

        // Handle failed tokens
        if (response.failureCount > 0) {
          await this._handleFailedTokens(response.responses, tokens);
        }

        // Save notifications to database
        await this._saveBulkNotifications(batch, title, body, data, priority);

      } catch (error) {
        logger.error(`❌ Error sending batch notification:`, error);
        results.failed += batch.length;
        results.details.push({
          batch: batch.length,
          error: error.message
        });
      }
    }

    return results;
  }

  /**
   * Send notification to all donors in a specific area
   */
  static async sendAreaNotification({ district, thana, bloodType, title, body, data = {} }) {
    try {
      // Query donors in the specified area
      let query = db.collection('users')
        .where('isDonor', '==', true)
        .where('isAvailable', '==', true);

      if (district) {
        query = query.where('district', '==', district);
      }

      if (thana) {
        query = query.where('thana', '==', thana);
      }

      if (bloodType) {
        query = query.where('bloodGroup', '==', bloodType);
      }

      const snapshot = await query.get();
      const donorIds = snapshot.docs.map(doc => doc.id);

      if (donorIds.length === 0) {
        return { success: false, error: 'No donors found in the specified area' };
      }

      // Send bulk notifications
      const result = await this.sendBulkNotifications({
        userIds: donorIds,
        title,
        body,
        data: {
          ...data,
          type: 'areaNotification',
          district,
          thana,
          bloodType
        },
        priority: 'high'
      });

      return {
        success: true,
        donorsNotified: donorIds.length,
        results: result
      };

    } catch (error) {
      logger.error('❌ Error sending area notification:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Helper methods
   */
  static _getAndroidPriority(priority) {
    switch (priority) {
      case 'critical': return 'high';
      case 'high': return 'high';
      case 'normal': return 'normal';
      case 'low': return 'normal';
      default: return 'normal';
    }
  }

  static _getAndroidNotificationPriority(priority) {
    switch (priority) {
      case 'critical': return 'max';
      case 'high': return 'high';
      case 'normal': return 'default';
      case 'low': return 'low';
      default: return 'default';
    }
  }

  static _getIOSInterruptionLevel(priority) {
    switch (priority) {
      case 'critical': return 'critical';
      case 'high': return 'time-sensitive';
      case 'normal': return 'active';
      case 'low': return 'passive';
      default: return 'active';
    }
  }

  static _getChannelId(type) {
    switch (type) {
      case 'emergencyRequest': return 'emergency_requests';
      case 'bloodRequest': return 'blood_requests';
      default: return 'general_notifications';
    }
  }

  static async _getBadgeCount(userId) {
    try {
      const snapshot = await db.collection('notifications')
        .where('recipientId', '==', userId)
        .where('isRead', '==', false)
        .get();
      return snapshot.size;
    } catch (error) {
      logger.error('Error getting badge count:', error);
      return 0;
    }
  }

  static async _removeInvalidToken(userId) {
    try {
      await db.collection('users').doc(userId).update({
        fcmToken: null,
        tokenUpdatedAt: new Date()
      });
      logger.info(`🗑️ Removed invalid FCM token for user ${userId}`);
    } catch (error) {
      logger.error('Error removing invalid token:', error);
    }
  }

  static async _getTokensForUsers(userIds) {
    try {
      const tokens = [];
      const chunks = [];
      
      // Firestore 'in' query limit is 10
      for (let i = 0; i < userIds.length; i += 10) {
        chunks.push(userIds.slice(i, i + 10));
      }

      for (const chunk of chunks) {
        const snapshot = await db.collection('users')
          .where('__name__', 'in', chunk)
          .get();

        snapshot.forEach(doc => {
          const data = doc.data();
          if (data.fcmToken) {
            tokens.push(data.fcmToken);
          }
        });
      }

      return tokens;
    } catch (error) {
      logger.error('Error getting tokens for users:', error);
      return [];
    }
  }

  static async _handleFailedTokens(responses, tokens) {
    const failedTokens = [];
    
    responses.forEach((response, index) => {
      if (!response.success) {
        const error = response.error;
        if (error.code === 'messaging/registration-token-not-registered') {
          failedTokens.push(tokens[index]);
        }
      }
    });

    // Remove invalid tokens from database
    if (failedTokens.length > 0) {
      const batch = db.batch();
      
      for (const token of failedTokens) {
        const userQuery = await db.collection('users')
          .where('fcmToken', '==', token)
          .get();
        
        userQuery.forEach(doc => {
          batch.update(doc.ref, { fcmToken: null });
        });
      }

      await batch.commit();
      logger.info(`🗑️ Removed ${failedTokens.length} invalid FCM tokens`);
    }
  }

  static async _saveBulkNotifications(userIds, title, body, data, priority) {
    const batch = db.batch();
    
    userIds.forEach(userId => {
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        recipientId: userId,
        title,
        body,
        data,
        priority,
        isRead: false,
        createdAt: new Date(),
        updatedAt: new Date()
      });
    });

    await batch.commit();
  }

  static async _scheduleReminderNotifications(requestId, donorId, urgency) {
    // This would integrate with a job scheduler like Bull Queue or node-cron
    // For now, we'll just log the scheduling
    logger.info(`📅 Scheduled reminder notifications for request ${requestId} (${urgency})`);
  }

  static _formatDate(date) {
    return new Intl.DateTimeFormat('en-GB', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    }).format(date);
  }
}

module.exports = { NotificationService };
