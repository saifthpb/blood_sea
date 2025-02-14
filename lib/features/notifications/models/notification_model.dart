import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      recipientId: map['recipientId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => NotificationType.message,
      ),
      additionalData: map['additionalData'],
    );
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
