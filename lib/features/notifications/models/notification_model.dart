// lib/features/notifications/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final String recipientId;
  final String senderId;
  final String senderName;
  final String? senderImage;
  final DateTime createdAt;
  final bool isRead;
  final String type;
  final Map<String, dynamic>? additionalData;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.senderImage,
    this.additionalData,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      recipientId: map['recipientId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      type: map['type'],
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImage: map['senderImage'] ?? '',
      additionalData: map['additionalData'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'recipientId': recipientId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'type': type,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'additionalData': additionalData,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    String? recipientId,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      recipientId: recipientId ?? this.recipientId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      additionalData: data ?? additionalData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        recipientId,
        createdAt,
        isRead,
        type,
        senderId,
        senderName,
        senderImage,
        additionalData,
      ];
}
