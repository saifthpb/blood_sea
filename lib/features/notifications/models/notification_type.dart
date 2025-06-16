// lib/features/notifications/models/notification_type.dart
import 'package:flutter/material.dart';

/// Enum representing different types of notifications in the application.
enum NotificationType {
  bloodRequest,
  requestAccepted,
  requestRejected,
  message,
  alert,
  info;

  /// Convert the enum to a string representation for storage
  String toValue() {
    switch (this) {
      case NotificationType.bloodRequest:
        return 'request';
      case NotificationType.requestAccepted:
        return 'accepted';
      case NotificationType.requestRejected:
        return 'rejected';
      case NotificationType.message:
        return 'message';
      case NotificationType.alert:
        return 'alert';
      case NotificationType.info:
        return 'info';
    }
  }

  /// Create a NotificationType from a string value
  static NotificationType fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'request':
        return NotificationType.bloodRequest;
      case 'accepted':
        return NotificationType.requestAccepted;
      case 'rejected':
        return NotificationType.requestRejected;
      case 'message':
        return NotificationType.message;
      case 'alert':
        return NotificationType.alert;
      case 'info':
        return NotificationType.info;
      default:
        return NotificationType.info;
    }
  }

  /// Get the display name of the notification type
  String get displayName {
    switch (this) {
      case NotificationType.bloodRequest:
        return 'Blood Request';
      case NotificationType.requestAccepted:
        return 'Request Accepted';
      case NotificationType.requestRejected:
        return 'Request Rejected';
      case NotificationType.message:
        return 'Message';
      case NotificationType.alert:
        return 'Alert';
      case NotificationType.info:
        return 'Information';
    }
  }

  /// Get the color associated with this notification type
  static Color getColor(NotificationType type) {
    switch (type) {
      case NotificationType.bloodRequest:
        return Colors.red;
      case NotificationType.requestAccepted:
        return Colors.green;
      case NotificationType.requestRejected:
        return Colors.orange;
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.alert:
        return Colors.red;
      case NotificationType.info:
        return Colors.green;
    }
  }
}