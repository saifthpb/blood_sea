import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMServiceFree {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize FCM
  static Future<void> initialize() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          print('FCM Token: $token');
          await _saveTokenToDatabase(token);
        }

        _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  // Save FCM token to Firestore
  static Future<void> _saveTokenToDatabase(String token) async {
    try {
      String? userId = getCurrentUserId();
      
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('FCM token saved to database');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    
    if (message.notification != null) {
      _showInAppNotification(message);
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    
    if (message.data['type'] == 'blood_request') {
      String? requestId = message.data['requestId'];
      if (requestId != null) {
        _navigateToBloodRequest(requestId);
      }
    }
  }

  static void _showInAppNotification(RemoteMessage message) {
    print('Showing in-app notification: ${message.notification?.title}');
  }

  static void _navigateToBloodRequest(String requestId) {
    print('Navigating to blood request: $requestId');
  }

  // FREE APPROACH: Store notification request in Firestore
  // Other users' apps will listen for these and show local notifications
  static Future<bool> createNotificationRequest({
    required String donorId,
    required String requestId,
    required String bloodType,
    required String location,
    required String requesterId,
  }) async {
    try {
      // Store notification request in Firestore
      await _firestore.collection('notification_requests').add({
        'donorId': donorId,
        'requestId': requestId,
        'requesterId': requesterId,
        'type': 'blood_request',
        'title': 'Blood Donation Request',
        'message': 'Someone needs $bloodType blood in $location.\n\nTap to respond to this request.',
        'bloodType': bloodType,
        'location': location,
        'isProcessed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Notification request created in Firestore');
      return true;
    } catch (e) {
      print('Error creating notification request: $e');
      return false;
    }
  }

  // Listen for notification requests for current user
  static Stream<QuerySnapshot> listenForNotificationRequests(String userId) {
    return _firestore
        .collection('notification_requests')
        .where('donorId', isEqualTo: userId)
        .where('isProcessed', isEqualTo: false)
        .snapshots();
  }

  // Mark notification request as processed
  static Future<void> markNotificationRequestProcessed(String requestId) async {
    try {
      await _firestore.collection('notification_requests').doc(requestId).update({
        'isProcessed': true,
        'processedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification request as processed: $e');
    }
  }

  // Show local notification when Firestore document is added
  static void showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    // You can use flutter_local_notifications package here
    // For now, just print to console
    print('LOCAL NOTIFICATION: $title - $body');
    
    // TODO: Implement flutter_local_notifications
    // This will show notification even without FCM server
  }

  static String? getCurrentUserId() {
    try {
      // Implement based on your auth system
      return null;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }
}
