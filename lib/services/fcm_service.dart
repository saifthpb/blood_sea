import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize FCM
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
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
        
        // Get FCM token
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          print('FCM Token: $token');
          await _saveTokenToDatabase(token);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle notification tap when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Handle notification tap when app is terminated
        RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  // Save FCM token to Firestore
  static Future<void> _saveTokenToDatabase(String token) async {
    try {
      // You'll need to get current user ID from your auth service
      String? userId = getCurrentUserId(); // Implement this based on your auth
      
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
    
    // Show in-app notification or update UI
    if (message.notification != null) {
      _showInAppNotification(message);
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    
    // Navigate based on notification data
    if (message.data['type'] == 'blood_request') {
      String? requestId = message.data['requestId'];
      if (requestId != null) {
        _navigateToBloodRequest(requestId);
      }
    }
  }

  // Show in-app notification
  static void _showInAppNotification(RemoteMessage message) {
    // You can implement a custom in-app notification widget here
    // or use a package like flutter_local_notifications
    print('Showing in-app notification: ${message.notification?.title}');
  }

  // Navigate to blood request screen
  static void _navigateToBloodRequest(String requestId) {
    // Implement navigation to blood request details screen
    print('Navigating to blood request: $requestId');
    // Example: Get.toNamed('/blood-request-details', arguments: requestId);
  }

  // Send push notification to specific user
  static Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token from database
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        print('User not found');
        return false;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String? fcmToken = userData['fcmToken'];

      if (fcmToken == null) {
        print('User FCM token not found');
        return false;
      }

      return await sendNotificationToToken(
        token: fcmToken,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      print('Error sending notification to user: $e');
      return false;
    }
  }

  // Send push notification to specific FCM token
  static Future<bool> sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // You'll need to implement server-side FCM sending
      // This is just a client-side example - move this to your backend
      
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY', // Replace with your server key
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
          },
          'data': data ?? {},
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
        return true;
      } else {
        print('Failed to send notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Send blood request notification
  static Future<bool> sendBloodRequestNotification({
    required String donorId,
    required String requestId,
    required String bloodType,
    required String location,
  }) async {
    return await sendNotificationToUser(
      userId: donorId,
      title: 'Blood Donation Request',
      body: 'Someone needs $bloodType blood in $location.\n\nTap to respond to this request.',
      data: {
        'type': 'blood_request',
        'requestId': requestId,
        'action': 'respond_to_request',
      },
    );
  }

  // Get current user ID - implement based on your auth system
  static String? getCurrentUserId() {
    // Implement this based on your authentication system
    // Example: return FirebaseAuth.instance.currentUser?.uid;
    try {
      // You can import firebase_auth and use:
      // return FirebaseAuth.instance.currentUser?.uid;
      
      // For now, return null - you'll need to implement this
      // based on your existing auth system
      return null; // Replace with actual implementation
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  
  // Handle background notification
  // You can save to local database or perform other background tasks
}
