import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceFree {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize local notifications
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(initializationSettings);
  }

  // Send blood request notification (Database + Local notification)
  static Future<bool> sendBloodRequestNotification({
    required String donorId,
    required String requestId,
    required String requesterId,
    required String bloodType,
    required String location,
    required String urgency,
  }) async {
    try {
      // 1. Save notification to database
      DocumentReference notificationRef = await _firestore.collection('notifications').add({
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

      // 2. Create a trigger document for real-time listening
      await _firestore.collection('notification_triggers').add({
        'donorId': donorId,
        'notificationId': notificationRef.id,
        'type': 'blood_request',
        'title': 'Blood Donation Request',
        'message': 'Someone needs $bloodType blood in $location.\n\nTap to respond to this request.',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Blood request notification saved to database');
      return true;
    } catch (e) {
      print('Error sending blood request notification: $e');
      return false;
    }
  }

  // Listen for notification triggers (real-time)
  static Stream<QuerySnapshot> listenForNotificationTriggers(String userId) {
    return _firestore
        .collection('notification_triggers')
        .where('donorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Show local notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'blood_request_channel',
      'Blood Request Notifications',
      channelDescription: 'Notifications for blood donation requests',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
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

  // Delete notification trigger after processing
  static Future<void> deleteNotificationTrigger(String triggerId) async {
    try {
      await _firestore.collection('notification_triggers').doc(triggerId).delete();
    } catch (e) {
      print('Error deleting notification trigger: $e');
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
}
