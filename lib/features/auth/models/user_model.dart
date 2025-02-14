// lib/features/auth/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum UserStatus {
  online,
  offline,
  away
}

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? bloodGroup;
  final String? district;
  final String? thana;
  final DateTime? lastDonationDate;
  final bool isDonor;
  final List<String>? donationHistory;
  // New chat-related fields
  final UserStatus status;
  final DateTime? lastSeen;
  final List<String>? activeChatIds;
  final String? fcmToken; // For push notifications
  final String? profileImageUrl;
  final Map<String, dynamic>? chatSettings; // User's chat preferences
  final bool isAvailable; // For blood donation availability

  const UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    this.bloodGroup,
    this.district,
    this.thana,
    this.lastDonationDate,
    this.isDonor = false,
    this.donationHistory,
    this.status = UserStatus.offline,
    this.lastSeen,
    this.activeChatIds,
    this.fcmToken,
    this.profileImageUrl,
    this.chatSettings,
    this.isAvailable = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      bloodGroup: map['bloodGroup'],
      district: map['district'],
      thana: map['thana'],
      lastDonationDate: map['lastDonationDate'] != null
          ? (map['lastDonationDate'] as Timestamp).toDate()
          : null,
      isDonor: map['isDonor'] ?? false,
      donationHistory: map['donationHistory'] != null
          ? List<String>.from(map['donationHistory'])
          : null,
      status: _parseUserStatus(map['status']),
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,
      activeChatIds: map['activeChatIds'] != null
          ? List<String>.from(map['activeChatIds'])
          : null,
      fcmToken: map['fcmToken'],
      profileImageUrl: map['profileImageUrl'],
      chatSettings: map['chatSettings'],
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'bloodGroup': bloodGroup,
      'district': district,
      'thana': thana,
      'lastDonationDate': lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      'isDonor': isDonor,
      'donationHistory': donationHistory,
      'status': status.name,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'activeChatIds': activeChatIds,
      'fcmToken': fcmToken,
      'profileImageUrl': profileImageUrl,
      'chatSettings': chatSettings,
      'isAvailable': isAvailable,
    };
  }

  static UserStatus _parseUserStatus(String? status) {
    switch (status) {
      case 'online':
        return UserStatus.online;
      case 'away':
        return UserStatus.away;
      default:
        return UserStatus.offline;
    }
  }

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? bloodGroup,
    String? district,
    String? thana,
    DateTime? lastDonationDate,
    bool? isDonor,
    List<String>? donationHistory,
    UserStatus? status,
    DateTime? lastSeen,
    List<String>? activeChatIds,
    String? fcmToken,
    String? profileImageUrl,
    Map<String, dynamic>? chatSettings,
    bool? isAvailable,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      district: district ?? this.district,
      thana: thana ?? this.thana,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      isDonor: isDonor ?? this.isDonor,
      donationHistory: donationHistory ?? this.donationHistory,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      activeChatIds: activeChatIds ?? this.activeChatIds,
      fcmToken: fcmToken ?? this.fcmToken,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      chatSettings: chatSettings ?? this.chatSettings,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        phoneNumber,
        bloodGroup,
        district,
        thana,
        lastDonationDate,
        isDonor,
        donationHistory,
        status,
        lastSeen,
        activeChatIds,
        fcmToken,
        profileImageUrl,
        chatSettings,
        isAvailable,
      ];

  // Helper methods for chat functionality
  bool get isOnline => status == UserStatus.online;

  String get displayName => name ?? email.split('@')[0];

  String get initials {
    if (name != null && name!.isNotEmpty) {
      final nameParts = name!.split(' ');
      if (nameParts.length > 1) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      }
      return name![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  String get statusText {
    switch (status) {
      case UserStatus.online:
        return 'Online';
      case UserStatus.away:
        return 'Away';
      case UserStatus.offline:
        if (lastSeen != null) {
          final difference = DateTime.now().difference(lastSeen!);
          if (difference.inMinutes < 60) {
            return 'Last seen ${difference.inMinutes} minutes ago';
          } else if (difference.inHours < 24) {
            return 'Last seen ${difference.inHours} hours ago';
          } else {
            return 'Last seen ${difference.inDays} days ago';
          }
        }
        return 'Offline';
    }
  }

  bool canDonateBlood() {
    if (!isDonor || !isAvailable) return false;
    if (lastDonationDate == null) return true;

    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    return lastDonationDate!.isBefore(threeMonthsAgo);
  }

  // Chat-related methods
  bool isInChat(String chatId) => activeChatIds?.contains(chatId) ?? false;

  bool canReceiveNotifications() => fcmToken != null;

  Map<String, dynamic> getChatSettings() => chatSettings ?? {
        'notifications': true,
        'sound': true,
        'vibration': true,
        'showPreviewMessages': true,
      };

  // Method to update user's online status
  Future<void> updateOnlineStatus(UserStatus newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': newStatus.name,
        'lastSeen': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  // Method to update FCM token
  Future<void> updateFcmToken(String? newToken) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': newToken,
      });
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  // Method to add active chat
  Future<void> addActiveChat(String chatId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'activeChatIds': FieldValue.arrayUnion([chatId]),
      });
    } catch (e) {
      debugPrint('Error adding active chat: $e');
    }
  }

  // Method to remove active chat
  Future<void> removeActiveChat(String chatId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'activeChatIds': FieldValue.arrayRemove([chatId]),
      });
    } catch (e) {
      debugPrint('Error removing active chat: $e');
    }
  }
}
