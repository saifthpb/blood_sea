import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createNotification({
    required String title,
    required String message,
    required String senderId,
    required String senderName,
    required String recipientId,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notification = NotificationModel(
        id: '', // Firestore will generate this
        title: title,
        message: message,
        senderId: senderId,
        senderName: senderName,
        recipientId: recipientId,
        createdAt: DateTime.now(),
        type: type,
        isRead: false, // Optional, can be set later
        additionalData: additionalData,
      );

      await _firestore
          .collection('notifications')
          .add(notification.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification: $e');
      }
      rethrow;
    }
  }

  Future<void> createTestNotification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('notifications').add({
        'title': 'Test Notification',
        'message': 'This is a test notification',
        'senderId': user.uid,
        'senderName': user.displayName ?? 'Anonymous',
        'recipientId': user.uid, // Sending to self for testing
        'createdAt': Timestamp.now(),
        'isRead': false,
        'type': 'message',
        'additionalData': {'test': true},
      });
    } catch (e) {
      debugPrint('Error creating test notification: $e');
    }
  }
}
