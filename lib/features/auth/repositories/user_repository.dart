// lib/features/auth/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user
  Future<void> createUser({
    required String uid,
    required String email,
    required String name,
    required String phoneNumber,
    required String bloodGroup,
    required String district,
    required String thana,
    required String userType,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'bloodGroup': bloodGroup,
        'district': district,
        'thana': thana,
        'userType': userType,
        'isDonor': userType == 'donor',
        'status': UserStatus.offline.name,
        'createdAt': Timestamp.now(),
        'lastSeen': Timestamp.now(),
        'isAvailable': true,
      });
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return getUserById(user.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update user status
  Future<void> updateUserStatus(String uid, UserStatus status) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': status.name,
        'lastSeen': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // Get donors by blood group
  Future<List<UserModel>> getDonorsByBloodGroup(String bloodGroup) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isDonor', isEqualTo: true)
          .where('bloodGroup', isEqualTo: bloodGroup)
          .where('isAvailable', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get donors: $e');
    }
  }

  // Get donors by location
  Future<List<UserModel>> getDonorsByLocation(String district) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isDonor', isEqualTo: true)
          .where('district', isEqualTo: district)
          .where('isAvailable', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get donors: $e');
    }
  }

  // Update FCM token
  Future<void> updateFcmToken(String uid, String? token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  // Add to donation history
  Future<void> addToDonationHistory(String uid, String requestId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'donationHistory': FieldValue.arrayUnion([requestId]),
        'lastDonationDate': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update donation history: $e');
    }
  }

  // Toggle donor availability
  Future<void> toggleDonorAvailability(String uid, bool isAvailable) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isAvailable': isAvailable,
      });
    } catch (e) {
      throw Exception('Failed to toggle availability: $e');
    }
  }

  // Search donors
  Future<List<UserModel>> searchDonors({
    String? bloodGroup,
    String? district,
    String? thana,
  }) async {
    try {
      Query query = _firestore.collection('users').where('isDonor', isEqualTo: true);

      if (bloodGroup != null) {
        query = query.where('bloodGroup', isEqualTo: bloodGroup);
      }

      if (district != null) {
        query = query.where('district', isEqualTo: district);
      }

      if (thana != null) {
        query = query.where('thana', isEqualTo: thana);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search donors: $e');
    }
  }

  // Get active donors
  Stream<List<UserModel>> getActiveDonors() {
    try {
      return _firestore
          .collection('users')
          .where('isDonor', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('status', isEqualTo: UserStatus.online.name)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw Exception('Failed to get active donors: $e');
    }
  }

  // Listen to user changes
  Stream<UserModel?> userChanges(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get user chat settings
  Future<Map<String, dynamic>> getUserChatSettings(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['chatSettings'] ?? {
          'notifications': true,
          'sound': true,
          'vibration': true,
          'showPreviewMessages': true,
        };
      }
      return {
        'notifications': true,
        'sound': true,
        'vibration': true,
        'showPreviewMessages': true,
      };
    } catch (e) {
      throw Exception('Failed to get chat settings: $e');
    }
  }

  // Update user chat settings
  Future<void> updateUserChatSettings(
    String uid,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'chatSettings': settings,
      });
    } catch (e) {
      throw Exception('Failed to update chat settings: $e');
    }
  }
}
