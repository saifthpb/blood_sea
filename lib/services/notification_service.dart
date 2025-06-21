import 'package:cloud_firestore/cloud_firestore.dart';
import 'fcm_service.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send complete notification (Database + Push)
  static Future<bool> sendBloodRequestNotification({
    required String donorId,
    required String requestId,
    required String requesterId,
    required String bloodType,
    required String location,
    required String urgency,
  }) async {
    try {
      // 1. Save notification to database first
      bool dbSaved = await _saveNotificationToDatabase(
        donorId: donorId,
        requestId: requestId,
        requesterId: requesterId,
        bloodType: bloodType,
        location: location,
        urgency: urgency,
      );

      // 2. Send push notification
      bool pushSent = await FCMService.sendBloodRequestNotification(
        donorId: donorId,
        requestId: requestId,
        bloodType: bloodType,
        location: location,
      );

      print('Database notification: ${dbSaved ? 'Success' : 'Failed'}');
      print('Push notification: ${pushSent ? 'Success' : 'Failed'}');

      // Return true if at least one method succeeded
      return dbSaved || pushSent;
    } catch (e) {
      print('Error sending blood request notification: $e');
      return false;
    }
  }

  // Save notification to database
  static Future<bool> _saveNotificationToDatabase({
    required String donorId,
    required String requestId,
    required String requesterId,
    required String bloodType,
    required String location,
    required String urgency,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'donorId': donorId,
        'requestId': requestId,
        'requesterId': requesterId,
        'type': 'blood_request',
        'title': 'Blood Donation Request',
        'message': 'Someone needs $bloodType blood in $location.\n\nTap to respond to this request.',
        'bloodType': bloodType,
        'location': location,
        'urgency': urgency,
        'isRead': false,
        'isResponded': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Notification saved to database successfully');
      return true;
    } catch (e) {
      print('Error saving notification to database: $e');
      return false;
    }
  }

  // Get notifications for a user
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('donorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mark notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark notification as responded
  static Future<bool> markNotificationAsResponded(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isResponded': true,
        'respondedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error marking notification as responded: $e');
      return false;
    }
  }

  // Get unread notification count
  static Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('donorId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Send general notification
  static Future<bool> sendGeneralNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Save to database
      await _firestore.collection('notifications').add({
        'donorId': userId,
        'type': type,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });

      // Send push notification
      await FCMService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: message,
        data: {
          'type': type,
          ...?additionalData,
        },
      );

      return true;
    } catch (e) {
      print('Error sending general notification: $e');
      return false;
    }
  }
}
