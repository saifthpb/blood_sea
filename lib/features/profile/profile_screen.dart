import 'package:blood_sea/shared/widgets/error_boundary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String? email;
  String? phone;
  String? bloodGroup;
  String? district;
  String? thana;
  String? photoUrl;
  String? lastDonateDate;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Get current user
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Try to fetch from users collection first
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      // If not found in users, try clients collection
      if (!userDoc.exists) {
        userDoc =
            await _firestore.collection('clients').doc(currentUser.uid).get();
      }

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'];
          email = data['email'];
          phone =
              data['phoneNumber'] ?? data['phone']; // Handle both field names
          bloodGroup = data['bloodGroup'];
          district = data['district'];
          thana = data['thana'];
          photoUrl = data['photoUrl'];
          lastDonateDate = data['lastDonationDate']?.toString();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'User profile not found';
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile: $e');
      }
      setState(() {
        error = 'Error loading profile: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      title: "Error Loading Profile",
      onRetry: fetchProfileData,
      child: _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchProfileData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoUrl != null && photoUrl!.isNotEmpty)
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(photoUrl!),
                backgroundColor: Colors.grey.shade200,
                onBackgroundImageError: (e, s) {
                  if (kDebugMode) {
                    print('Error loading profile image: $e');
                  }
                },
              ),
            ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Personal Information',
            children: [
              _buildInfoRow('Name', name),
              _buildInfoRow('Email', email),
              _buildInfoRow('Phone', phone),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Location Information',
            children: [
              _buildInfoRow('District', district),
              _buildInfoRow('Thana', thana),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Blood Donation Information',
            children: [
              _buildInfoRow('Blood Group', bloodGroup),
              _buildInfoRow('Last Donation', lastDonateDate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value ?? 'Not Available',
            style: TextStyle(
              fontSize: 16,
              color: value == null ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
