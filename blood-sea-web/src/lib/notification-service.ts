import { adminMessaging, adminDb } from './firebase-admin';
import { Message, MulticastMessage } from 'firebase-admin/messaging';

export interface NotificationData {
  userId?: string;
  userIds?: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
  priority?: 'low' | 'normal' | 'high' | 'critical';
  type?: string;
  fcmToken?: string;
  fcmTokens?: string[];
}

export interface BloodRequestData {
  donorId: string;
  requesterId: string;
  bloodType: string;
  hospital: string;
  urgency: 'low' | 'normal' | 'high' | 'critical';
  location?: string;
  contactInfo?: string;
}

export class NotificationService {
  private static instance: NotificationService;

  public static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  /**
   * Send notification to a single user
   */
  async sendToUser(data: NotificationData): Promise<{ success: boolean; messageId?: string; error?: string }> {
    try {
      let fcmToken = data.fcmToken;

      // If no FCM token provided, get it from user document
      if (!fcmToken && data.userId) {
        const userDoc = await adminDb.collection('users').doc(data.userId).get();
        if (userDoc.exists) {
          fcmToken = userDoc.data()?.fcmToken;
        }
      }

      if (!fcmToken) {
        throw new Error('No FCM token available for user');
      }

      const message: Message = {
        notification: {
          title: data.title,
          body: data.body,
        },
        data: {
          type: data.type || 'general',
          priority: data.priority || 'normal',
          timestamp: new Date().toISOString(),
          ...data.data,
        },
        token: fcmToken,
        android: {
          notification: {
            channelId: data.type || 'general',
            priority: this.getAndroidPriority(data.priority),
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: data.title,
                body: data.body,
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      const response = await adminMessaging.send(message);

      // Log notification to Firestore
      await this.logNotification({
        userId: data.userId,
        title: data.title,
        body: data.body,
        type: data.type || 'general',
        priority: data.priority || 'normal',
        status: 'sent',
        messageId: response,
        timestamp: new Date(),
      });

      return { success: true, messageId: response };
    } catch (error: any) {
      console.error('Error sending notification:', error);
      
      // Log failed notification
      if (data.userId) {
        await this.logNotification({
          userId: data.userId,
          title: data.title,
          body: data.body,
          type: data.type || 'general',
          priority: data.priority || 'normal',
          status: 'failed',
          error: error.message,
          timestamp: new Date(),
        });
      }

      return { success: false, error: error.message };
    }
  }

  /**
   * Send notification to multiple users
   */
  async sendToMultipleUsers(data: NotificationData): Promise<{ 
    success: boolean; 
    successCount: number; 
    failureCount: number; 
    responses?: any[] 
  }> {
    try {
      let fcmTokens = data.fcmTokens || [];

      // If no FCM tokens provided, get them from user documents
      if (fcmTokens.length === 0 && data.userIds && data.userIds.length > 0) {
        const userDocs = await adminDb.collection('users')
          .where('__name__', 'in', data.userIds)
          .get();

        fcmTokens = userDocs.docs
          .map(doc => doc.data().fcmToken)
          .filter(token => token);
      }

      if (fcmTokens.length === 0) {
        throw new Error('No FCM tokens available');
      }

      const message: MulticastMessage = {
        notification: {
          title: data.title,
          body: data.body,
        },
        data: {
          type: data.type || 'general',
          priority: data.priority || 'normal',
          timestamp: new Date().toISOString(),
          ...data.data,
        },
        tokens: fcmTokens,
        android: {
          notification: {
            channelId: data.type || 'general',
            priority: this.getAndroidPriority(data.priority),
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: data.title,
                body: data.body,
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      const response = await adminMessaging.sendEachForMulticast(message);

      // Log notifications
      const logPromises = (data.userIds || []).map((userId, index) => 
        this.logNotification({
          userId,
          title: data.title,
          body: data.body,
          type: data.type || 'general',
          priority: data.priority || 'normal',
          status: response.responses[index]?.success ? 'sent' : 'failed',
          messageId: response.responses[index]?.messageId,
          error: response.responses[index]?.error?.message,
          timestamp: new Date(),
        })
      );

      await Promise.all(logPromises);

      return {
        success: response.successCount > 0,
        successCount: response.successCount,
        failureCount: response.failureCount,
        responses: response.responses,
      };
    } catch (error: any) {
      console.error('Error sending bulk notifications:', error);
      return {
        success: false,
        successCount: 0,
        failureCount: data.userIds?.length || 0,
      };
    }
  }

  /**
   * Send blood request notification to eligible donors
   */
  async sendBloodRequestNotification(requestData: BloodRequestData): Promise<{
    success: boolean;
    notifiedDonors: number;
    error?: string;
  }> {
    try {
      // Find eligible donors based on blood type compatibility
      const eligibleBloodTypes = this.getCompatibleBloodTypes(requestData.bloodType);
      
      const donorsQuery = await adminDb.collection('users')
        .where('role', '==', 'donor')
        .where('bloodType', 'in', eligibleBloodTypes)
        .where('isAvailable', '==', true)
        .get();

      const eligibleDonors = donorsQuery.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      if (eligibleDonors.length === 0) {
        return {
          success: false,
          notifiedDonors: 0,
          error: 'No eligible donors found'
        };
      }

      // Send notifications to eligible donors
      const notificationData: NotificationData = {
        userIds: eligibleDonors.map(donor => donor.id),
        title: `Urgent: ${requestData.bloodType} Blood Needed`,
        body: `${requestData.hospital} needs ${requestData.bloodType} blood. Can you help?`,
        type: 'blood_request',
        priority: requestData.urgency,
        data: {
          requestId: `req_${Date.now()}`,
          bloodType: requestData.bloodType,
          hospital: requestData.hospital,
          urgency: requestData.urgency,
          location: requestData.location || '',
          contactInfo: requestData.contactInfo || '',
        },
      };

      const result = await this.sendToMultipleUsers(notificationData);

      // Log blood request
      await adminDb.collection('blood_requests').add({
        ...requestData,
        timestamp: new Date(),
        notifiedDonors: result.successCount,
        status: 'active',
      });

      return {
        success: result.success,
        notifiedDonors: result.successCount,
      };
    } catch (error: any) {
      console.error('Error sending blood request notification:', error);
      return {
        success: false,
        notifiedDonors: 0,
        error: error.message,
      };
    }
  }

  /**
   * Get compatible blood types for donation
   */
  private getCompatibleBloodTypes(requestedType: string): string[] {
    const compatibility: Record<string, string[]> = {
      'O-': ['O-'],
      'O+': ['O-', 'O+'],
      'A-': ['O-', 'A-'],
      'A+': ['O-', 'O+', 'A-', 'A+'],
      'B-': ['O-', 'B-'],
      'B+': ['O-', 'O+', 'B-', 'B+'],
      'AB-': ['O-', 'A-', 'B-', 'AB-'],
      'AB+': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
    };

    return compatibility[requestedType] || [requestedType];
  }

  /**
   * Get Android notification priority
   */
  private getAndroidPriority(priority?: string): 'min' | 'low' | 'default' | 'high' | 'max' {
    switch (priority) {
      case 'critical': return 'max';
      case 'high': return 'high';
      case 'normal': return 'default';
      case 'low': return 'low';
      default: return 'default';
    }
  }

  /**
   * Log notification to Firestore
   */
  private async logNotification(logData: any): Promise<void> {
    try {
      await adminDb.collection('notifications').add(logData);
    } catch (error) {
      console.error('Error logging notification:', error);
    }
  }
}

export const notificationService = NotificationService.getInstance();
