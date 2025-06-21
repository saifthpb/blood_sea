import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FCMServiceV2 {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize FCM (same as before)
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

  // NEW: Send notification via your backend API
  static Future<bool> sendNotificationViaBackend({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Replace with your actual backend API endpoint
      final response = await http.post(
        Uri.parse('https://your-backend-api.com/send-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Your backend auth
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent via backend successfully');
        return true;
      } else {
        print('Failed to send notification via backend: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending notification via backend: $e');
      return false;
    }
  }

  // NEW: Use Firebase Functions (Cloud Functions)
  static Future<bool> sendNotificationViaCloudFunction({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Call your Firebase Cloud Function
      final response = await http.post(
        Uri.parse('https://your-region-your-project.cloudfunctions.net/sendNotification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent via Cloud Function successfully');
        return true;
      } else {
        print('Failed to send notification via Cloud Function: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending notification via Cloud Function: $e');
      return false;
    }
  }

  // Send blood request notification (updated)
  static Future<bool> sendBloodRequestNotification({
    required String donorId,
    required String requestId,
    required String bloodType,
    required String location,
  }) async {
    // Use backend API instead of direct FCM
    return await sendNotificationViaBackend(
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
