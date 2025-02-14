import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNotification({
    required String title,
    required String message,
    required String senderId,
    required String senderName,
    required String recipientId,
    required NotificationType type,
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
}
