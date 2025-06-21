import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../models/notification_type.dart';

class BloodRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send a blood request notification to a donor
  Future<bool> sendBloodRequest({
    required String donorId,
    required String donorName,
    required String bloodGroup,
    required String patientLocation,
    required String requiredDate,
    String? urgencyLevel = 'Normal',
    String? additionalMessage,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get current user's profile information
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;
      final senderName = userData['name'] ?? currentUser.displayName ?? 'Anonymous User';
      final senderPhone = userData['phoneNumber'] ?? '';

      // Create the notification
      final notification = NotificationModel(
        id: '', // Firestore will generate this
        title: '🩸 Blood Request - $bloodGroup',
        message: _buildNotificationMessage(
          senderName: senderName,
          bloodGroup: bloodGroup,
          patientLocation: patientLocation,
          requiredDate: requiredDate,
          urgencyLevel: urgencyLevel,
          additionalMessage: additionalMessage,
        ),
        senderId: currentUser.uid,
        senderName: senderName,
        recipientId: donorId,
        createdAt: DateTime.now(),
        type: NotificationType.bloodRequest.toValue(),
        isRead: false,
        additionalData: {
          'bloodGroup': bloodGroup,
          'patientLocation': patientLocation,
          'requiredDate': requiredDate,
          'urgencyLevel': urgencyLevel,
          'senderPhone': senderPhone,
          'donorName': donorName,
          'requestType': 'blood_donation',
          'additionalMessage': additionalMessage,
        },
      );

      // Save notification to Firestore
      final docRef = await _firestore
          .collection('notifications')
          .add(notification.toMap());

      // Also create a blood request record for tracking
      await _createBloodRequestRecord(
        requestId: docRef.id,
        donorId: donorId,
        donorName: donorName,
        bloodGroup: bloodGroup,
        patientLocation: patientLocation,
        requiredDate: requiredDate,
        urgencyLevel: urgencyLevel,
        senderName: senderName,
        senderPhone: senderPhone,
        additionalMessage: additionalMessage,
      );

      if (kDebugMode) {
        print('✅ Blood request sent successfully to $donorName');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending blood request: $e');
      }
      rethrow;
    }
  }

  /// Create a blood request record for tracking purposes
  Future<void> _createBloodRequestRecord({
    required String requestId,
    required String donorId,
    required String donorName,
    required String bloodGroup,
    required String patientLocation,
    required String requiredDate,
    required String? urgencyLevel,
    required String senderName,
    required String senderPhone,
    String? additionalMessage,
  }) async {
    final currentUser = _auth.currentUser!;

    await _firestore.collection('blood_requests').add({
      'notificationId': requestId,
      'requesterId': currentUser.uid,
      'requesterName': senderName,
      'requesterPhone': senderPhone,
      'donorId': donorId,
      'donorName': donorName,
      'bloodGroup': bloodGroup,
      'patientLocation': patientLocation,
      'requiredDate': requiredDate,
      'urgencyLevel': urgencyLevel,
      'additionalMessage': additionalMessage,
      'status': 'pending', // pending, accepted, rejected, completed
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Build a user-friendly notification message
  String _buildNotificationMessage({
    required String senderName,
    required String bloodGroup,
    required String patientLocation,
    required String requiredDate,
    String? urgencyLevel,
    String? additionalMessage,
  }) {
    String urgencyText = '';
    if (urgencyLevel != null && urgencyLevel.toLowerCase() == 'urgent') {
      urgencyText = '🚨 URGENT: ';
    }

    String baseMessage = '${urgencyText}$senderName needs $bloodGroup blood at $patientLocation on $requiredDate.';
    
    if (additionalMessage != null && additionalMessage.isNotEmpty) {
      baseMessage += '\n\nMessage: $additionalMessage';
    }

    baseMessage += '\n\nTap to respond to this request.';

    return baseMessage;
  }

  /// Get blood requests for the current user (as a donor)
  Stream<List<Map<String, dynamic>>> getBloodRequestsForDonor() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('blood_requests')
        .where('donorId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get blood requests sent by the current user (as a requester)
  Stream<List<Map<String, dynamic>>> getBloodRequestsByRequester() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('blood_requests')
        .where('requesterId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Update blood request status (accept/reject)
  Future<void> updateRequestStatus({
    required String requestId,
    required String status, // 'accepted', 'rejected', 'completed'
    String? responseMessage,
  }) async {
    try {
      await _firestore.collection('blood_requests').doc(requestId).update({
        'status': status,
        'responseMessage': responseMessage,
        'respondedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Also send a notification back to the requester
      final requestDoc = await _firestore
          .collection('blood_requests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;
        await _sendResponseNotification(
          requestData: requestData,
          status: status,
          responseMessage: responseMessage,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating request status: $e');
      }
      rethrow;
    }
  }

  /// Send response notification back to requester
  Future<void> _sendResponseNotification({
    required Map<String, dynamic> requestData,
    required String status,
    String? responseMessage,
  }) async {
    final currentUser = _auth.currentUser!;
    
    // Get donor's name
    final donorDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    final donorName = donorDoc.data()?['name'] ?? 'A donor';
    
    String title;
    NotificationType notificationType;
    String message;

    switch (status) {
      case 'accepted':
        title = '✅ Blood Request Accepted';
        notificationType = NotificationType.requestAccepted;
        message = '$donorName has accepted your blood request for ${requestData['bloodGroup']} blood.';
        break;
      case 'rejected':
        title = '❌ Blood Request Declined';
        notificationType = NotificationType.requestRejected;
        message = '$donorName is unable to fulfill your blood request for ${requestData['bloodGroup']} blood.';
        break;
      default:
        return;
    }

    if (responseMessage != null && responseMessage.isNotEmpty) {
      message += '\n\nMessage: $responseMessage';
    }

    final notification = NotificationModel(
      id: '',
      title: title,
      message: message,
      senderId: currentUser.uid,
      senderName: donorName,
      recipientId: requestData['requesterId'],
      createdAt: DateTime.now(),
      type: notificationType.toValue(),
      isRead: false,
      additionalData: {
        'originalRequestId': requestData['id'],
        'bloodGroup': requestData['bloodGroup'],
        'status': status,
        'responseMessage': responseMessage,
      },
    );

    await _firestore.collection('notifications').add(notification.toMap());
  }
}
