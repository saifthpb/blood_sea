import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationType {
  bloodRequest,
  bloodRequestResponse,
  emergencyRequest,
  generalAnnouncement,
  donationReminder,
  systemUpdate
}

enum NotificationPriority { low, normal, high, critical }

class EnhancedNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Your web API endpoint (we'll create this)
  static const String _apiBaseUrl = 'https://your-api-domain.com/api';
  
  // Notification channels for Android
  static const String _bloodRequestChannelId = 'blood_requests';
  static const String _emergencyChannelId = 'emergency_requests';
  static const String _generalChannelId = 'general_notifications';

  /// Initialize the enhanced notification service
  static Future<void> initialize() async {
    try {
      await _initializeLocalNotifications();
      await _initializeFirebaseMessaging();
      await _createNotificationChannels();
      print('✅ Enhanced Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Enhanced Notification Service: $e');
    }
  }

  /// Initialize local notifications with proper channels
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
        sound: RawResourceAndroidNotificationSound('blood_request_sound'),
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
        sound: RawResourceAndroidNotificationSound('emergency_sound'),
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

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(bloodRequestChannel);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(emergencyChannel);

      await flutterLocalNotificationsPlugin
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
      
      // Get and save FCM token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
        await _saveTokenToAPI(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        await _saveTokenToDatabase(token);
        await _saveTokenToAPI(token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Handle terminated app message taps
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessageTap(initialMessage);
      }
    }
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

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Received foreground message: ${message.messageId}');
    
    // Save to local database
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

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final NotificationType type = _getNotificationType(message.data['type']);
    final NotificationPriority priority = _getPriority(message.data['priority']);
    
    String channelId;
    AndroidNotificationDetails androidDetails;
    
    switch (type) {
      case NotificationType.emergencyRequest:
        channelId = _emergencyChannelId;
        androidDetails = AndroidNotificationDetails(
          channelId,
          'Emergency Requests',
          channelDescription: 'Critical emergency blood requests',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@drawable/emergency_icon',
          color: Colors.red,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 500]),
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );
        break;
      
      case NotificationType.bloodRequest:
        channelId = _bloodRequestChannelId;
        androidDetails = AndroidNotificationDetails(
          channelId,
          'Blood Requests',
          channelDescription: 'Blood donation requests',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/blood_drop_icon',
          color: Colors.redAccent,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        );
        break;
      
      default:
        channelId = _generalChannelId;
        androidDetails = AndroidNotificationDetails(
          channelId,
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
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

  /// Send enhanced blood request notification
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
      final NotificationType type = urgency.toLowerCase() == 'emergency' 
          ? NotificationType.emergencyRequest 
          : NotificationType.bloodRequest;
      
      final Map<String, dynamic> notificationData = {
        'type': type.name,
        'donorId': donorId,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'requesterPhone': requesterPhone,
        'bloodType': bloodType,
        'location': location,
        'urgency': urgency,
        'requiredDate': requiredDate.toIso8601String(),
        'additionalMessage': additionalMessage,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // 1. Save to Firestore
      await _saveNotificationToFirestore(notificationData);

      // 2. Send via Web API (more reliable)
      bool apiSent = await _sendViaAPI(
        userId: donorId,
        title: urgency.toLowerCase() == 'emergency' 
            ? '🚨 EMERGENCY: $bloodType Blood Needed'
            : '🩸 Blood Request: $bloodType',
        body: '$requesterName needs $bloodType blood at $location on ${_formatDate(requiredDate)}',
        data: notificationData,
        priority: urgency.toLowerCase() == 'emergency' 
            ? NotificationPriority.critical 
            : NotificationPriority.high,
      );

      // 3. Fallback to direct FCM if API fails
      if (!apiSent) {
        await _sendDirectFCM(
          userId: donorId,
          title: urgency.toLowerCase() == 'emergency' 
              ? '🚨 EMERGENCY: $bloodType Blood Needed'
              : '🩸 Blood Request: $bloodType',
          body: '$requesterName needs $bloodType blood at $location',
          data: notificationData,
        );
      }

      return true;
    } catch (e) {
      print('❌ Error sending blood request notification: $e');
      return false;
    }
  }

  /// Send notification via Web API
  static Future<bool> _sendViaAPI({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required NotificationPriority priority,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data,
          'priority': priority.name,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent via API successfully');
        return true;
      } else {
        print('❌ API notification failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification via API: $e');
      return false;
    }
  }

  /// Send direct FCM notification (fallback)
  static Future<bool> _sendDirectFCM({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Get user's FCM token
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final String? fcmToken = userData['fcmToken'];

      if (fcmToken == null) return false;

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${await _getServerKey()}',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'badge': await _getBadgeCount() + 1,
          },
          'data': data,
          'priority': 'high',
          'content_available': true,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error sending direct FCM: $e');
      return false;
    }
  }

  /// Save notification to Firestore
  static Future<void> _saveNotificationToFirestore(Map<String, dynamic> data) async {
    await _firestore.collection('notifications').add({
      ...data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save notification locally for offline access
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

  /// Save FCM token to database
  static Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
          'appVersion': '1.0.0', // Get from package info
        });
      }
    } catch (e) {
      print('❌ Error saving token to database: $e');
    }
  }

  /// Save FCM token to API
  static Future<void> _saveTokenToAPI(String token) async {
    try {
      await http.post(
        Uri.parse('$_apiBaseUrl/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'fcmToken': token,
          'platform': Platform.operatingSystem,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print('❌ Error saving token to API: $e');
    }
  }

  /// Navigate based on notification data
  static void _navigateBasedOnNotification(Map<String, dynamic> data) {
    // Implement navigation logic based on notification type
    final String type = data['type'] ?? '';
    
    switch (type) {
      case 'bloodRequest':
      case 'emergencyRequest':
        // Navigate to blood request details
        // Get.toNamed('/blood-request-details', arguments: data);
        break;
      case 'bloodRequestResponse':
        // Navigate to request status
        // Get.toNamed('/request-status', arguments: data);
        break;
      default:
        // Navigate to notifications list
        // Get.toNamed('/notifications');
    }
  }

  /// Update badge count
  static Future<void> _updateBadgeCount() async {
    final count = await _getUnreadCount();
    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(badge: true);
    // Update badge count on iOS
  }

  /// Get unread notification count
  static Future<int> _getUnreadCount() async {
    // Implement logic to get unread count from Firestore
    return 0;
  }

  /// Get badge count
  static Future<int> _getBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('badge_count') ?? 0;
  }

  /// Helper methods
  static NotificationType _getNotificationType(String? type) {
    switch (type) {
      case 'bloodRequest': return NotificationType.bloodRequest;
      case 'emergencyRequest': return NotificationType.emergencyRequest;
      case 'bloodRequestResponse': return NotificationType.bloodRequestResponse;
      default: return NotificationType.generalAnnouncement;
    }
  }

  static NotificationPriority _getPriority(String? priority) {
    switch (priority) {
      case 'critical': return NotificationPriority.critical;
      case 'high': return NotificationPriority.high;
      case 'low': return NotificationPriority.low;
      default: return NotificationPriority.normal;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static Future<String> _getAuthToken() async {
    // Get Firebase Auth token
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken() ?? '';
  }

  static Future<String> _getServerKey() async {
    // Get FCM server key from secure storage or API
    return 'YOUR_FCM_SERVER_KEY';
  }
}
