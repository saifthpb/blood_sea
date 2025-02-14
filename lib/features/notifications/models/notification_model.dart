import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum NotificationType {
  bloodRequest,
  requestAccepted,
  requestRejected,
  message,
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final String senderId;
  final String senderName;
  final String recipientId;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? additionalData;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.additionalData,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    try {
      return NotificationModel(
        id: id,
        title: map['title'] ?? 'No Title',
        message: map['message'] ?? 'No Message',
        senderId: map['senderId'] ?? '',
        senderName: map['senderName'] ?? 'Unknown',
        recipientId: map['recipientId'] ?? '',
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        isRead: map['isRead'] ?? false,
        type: _parseNotificationType(map['type']),
        additionalData: map['additionalData'] as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('Error parsing notification: $e');
      rethrow;
    }
  }
  
  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'bloodRequest':
        return NotificationType.bloodRequest;
      case 'requestAccepted':
        return NotificationType.requestAccepted;
      case 'requestRejected':
        return NotificationType.requestRejected;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.message;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'type': type.name,
      'additionalData': additionalData,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        senderId,
        senderName,
        recipientId,
        createdAt,
        isRead,
        type,
        additionalData,
      ];
}
