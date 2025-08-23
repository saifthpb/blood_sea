import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationPriority { low, normal, high, critical }

class NotificationServiceEnhanced {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Your API endpoint - replace with your actual domain
  static const String _apiBaseUrl = 'https://your-api-domain.com/api';
  
  // Notification channels
  static const String _bloodRequestChannelId = 'blood_requests';
  static const String _emergencyChannelId = 'emergency_requests';
  static const String _generalChannelId = 'general_notifications';

  /// Initialize the notification service
  static Future<void> initialize() async {
    try {
      await _initializeLocalNotifications();
      await _initializeFirebaseMessaging();
      await _createNotificationChannels();
      await _syncTokenWithAPI();
      
      print('✅ Enhanced Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Enhanced Notification Service: $e');
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  /// Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Blood Request Channel
      const AndroidNotificationChannel bloodRequestChannel =
          AndroidNotificationChannel(
        _bloodRequestChannelId,
        'Blood Requests',
        description: 'Notifications for blood donation requests',
        importance: Importance.high,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      );

      // Emergency Channel
      const AndroidNotificationChannel emergencyChannel =
          AndroidNotificationChannel(
        _emergencyChannelId,
        'Emergency Requests',
        description: 'Critical emergency blood requests',
        importance: Importance.max,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 500]),
      );

      // General Channel
      const AndroidNotificationChannel generalChannel =
          AndroidNotificationChannel(
        _generalChannelId,
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(bloodRequestChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(emergencyChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(generalChannel);
    }
  }

  /// Initialize Firebase Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permission');
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Handle terminated app message taps
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessageTap(initialMessage);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_syncTokenWithAPI);
    }
  }

  /// Sync FCM token with API
  static Future<void> _syncTokenWithAPI() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToAPI(token);
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      print('❌ Error syncing token with API: $e');
    }
  }

  /// Save FCM token to API
  static Future<void> _saveTokenToAPI(String token) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) return;

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'fcmToken': token,
          'platform': Platform.operatingSystem,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token synced with API successfully');
      } else {
        print('❌ Failed to sync FCM token with API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error saving token to API: $e');
    }
  }

  /// Save FCM token to Firestore (fallback)
  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
        });
      }
    } catch (e) {
      print('❌ Error saving token to Firestore: $e');
    }
  }

  /// Send blood request notification via API
  static Future<bool> sendBloodRequestNotification({
    required String donorId,
    required String requesterId,
    required String requesterName,
    required String requesterPhone,
    required String bloodType,
    required String location,
    required String urgency,
    required DateTime requiredDate,
    String? additionalMessage,
  }) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        print('❌ No auth token available');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/notifications/blood-request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'donorId': donorId,
          'requesterId': requesterId,
          'requesterName': requesterName,
          'requesterPhone': requesterPhone,
          'bloodType': bloodType,
          'location': location,
          'urgency': urgency,
          'requiredDate': requiredDate.toIso8601String(),
          'additionalMessage': additionalMessage,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Blood request notification sent successfully');
        print('📧 Notification ID: ${responseData['notificationId']}');
        print('🩸 Request ID: ${responseData['requestId']}');
        return true;
      } else {
        print('❌ Failed to send blood request notification: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending blood request notification: $e');
      return false;
    }
  }

  /// Send general notification via API
  static Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) return false;

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
          'priority': priority.name,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }

  /// Send bulk notifications via API
  static Future<Map<String, dynamic>> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {'success': false, 'error': 'No auth token'};
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/notifications/bulk-send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'userIds': userIds,
          'title': title,
          'body': body,
          'data': data ?? {},
          'priority': priority.name,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Bulk notifications sent successfully');
        return responseData['results'];
      } else {
        print('❌ Failed to send bulk notifications: ${response.statusCode}');
        return {'success': false, 'error': 'API error'};
      }
    } catch (e) {
      print('❌ Error sending bulk notifications: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get user notifications from API
  static Future<List<Map<String, dynamic>>> getUserNotifications({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      final authToken = await _getAuthToken();
      final user = FirebaseAuth.instance.currentUser;
      
      if (authToken == null || user == null) return [];

      final uri = Uri.parse('$_apiBaseUrl/notifications/user/${user.uid}')
          .replace(queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'unreadOnly': unreadOnly.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(responseData['notifications']);
      } else {
        print('❌ Failed to get notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) return false;

      final response = await http.put(
        Uri.parse('$_apiBaseUrl/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Update notification settings
  static Future<bool> updateNotificationSettings({
    bool? bloodRequests,
    bool? emergencyRequests,
    bool? generalAnnouncements,
    bool? donationReminders,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) return false;

      final settings = <String, dynamic>{};
      if (bloodRequests != null) settings['bloodRequests'] = bloodRequests;
      if (emergencyRequests != null) settings['emergencyRequests'] = emergencyRequests;
      if (generalAnnouncements != null) settings['generalAnnouncements'] = generalAnnouncements;
      if (donationReminders != null) settings['donationReminders'] = donationReminders;
      if (soundEnabled != null) settings['soundEnabled'] = soundEnabled;
      if (vibrationEnabled != null) settings['vibrationEnabled'] = vibrationEnabled;

      final response = await http.put(
        Uri.parse('$_apiBaseUrl/users/notification-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(settings),
      );

      if (response.statusCode == 200) {
        print('✅ Notification settings updated successfully');
        return true;
      } else {
        print('❌ Failed to update notification settings: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating notification settings: $e');
      return false;
    }
  }

  /// Send test notification
  static Future<bool> sendTestNotification() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) return false;

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/test-notification'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Test notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send test notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
      return false;
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Received foreground message: ${message.messageId}');
    
    // Save to local storage
    _saveNotificationLocally(message);
    
    // Show local notification
    _showLocalNotification(message);
    
    // Update badge count
    _updateBadgeCount();
  }

  /// Handle background message tap
  static void _handleBackgroundMessageTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.messageId}');
    _navigateBasedOnNotification(message.data);
  }

  /// Handle notification tap
  static void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _navigateBasedOnNotification(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final String type = message.data['type'] ?? 'general';
    final String urgency = message.data['urgency'] ?? 'normal';
    
    String channelId;
    AndroidNotificationDetails androidDetails;
    
    if (type == 'emergencyRequest' || urgency == 'emergency') {
      channelId = _emergencyChannelId;
      androidDetails = AndroidNotificationDetails(
        channelId,
        'Emergency Requests',
        channelDescription: 'Critical emergency blood requests',
        importance: Importance.max,
        priority: Priority.max,
        color: Colors.red,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 500]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );
    } else if (type == 'bloodRequest') {
      channelId = _bloodRequestChannelId;
      androidDetails = AndroidNotificationDetails(
        channelId,
        'Blood Requests',
        channelDescription: 'Blood donation requests',
        importance: Importance.high,
        priority: Priority.high,
        color: Colors.redAccent,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      );
    } else {
      channelId = _generalChannelId;
      androidDetails = AndroidNotificationDetails(
        channelId,
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
    }

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Blood Sea',
      message.notification?.body ?? 'You have a new notification',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Save notification locally
  static Future<void> _saveNotificationLocally(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notifications = prefs.getStringList('local_notifications') ?? [];
    
    notifications.insert(0, jsonEncode({
      'id': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
    }));

    // Keep only last 100 notifications
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    await prefs.setStringList('local_notifications', notifications);
  }

  /// Navigate based on notification data
  static void _navigateBasedOnNotification(Map<String, dynamic> data) {
    final String type = data['type'] ?? '';
    
    switch (type) {
      case 'bloodRequest':
      case 'emergencyRequest':
        // Navigate to blood request details
        // Get.toNamed('/blood-request-details', arguments: data);
        print('🩸 Navigate to blood request: ${data['requestId']}');
        break;
      case 'bloodRequestResponse':
        // Navigate to request status
        // Get.toNamed('/request-status', arguments: data);
        print('📋 Navigate to request status: ${data['requestId']}');
        break;
      default:
        // Navigate to notifications list
        // Get.toNamed('/notifications');
        print('📱 Navigate to notifications');
    }
  }

  /// Update badge count
  static Future<void> _updateBadgeCount() async {
    // Implementation for updating badge count
  }

  /// Get Firebase Auth token
  static Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return await user?.getIdToken();
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  /// Clear all notifications
  static Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_notifications');
  }

  /// Get notification permission status
  static Future<bool> hasNotificationPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
