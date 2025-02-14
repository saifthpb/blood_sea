import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  bool _isDonor = false; // Tracks whether the donor section should be shown

  // Controllers for user registration
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controllers for donor-specific fields
  final _bloodGroupController = TextEditingController();
  final _addressController = TextEditingController();
  final _lastDonateDateController = TextEditingController();
  // You might need an image picker for the photo upload field

  void _toggleDonorSection() {
    setState(() {
      _isDonor = !_isDonor;
    });
  }

  Future<void> _registerUser() async {
    // Handle user registration logic, including Firebase authentication
    // Add user data to Firestore (e.g., full name, email, etc.)

    if (_isDonor) {
      // Add donor-specific data to a different collection
      await FirebaseFirestore.instance
          .collection('donors')
          .doc(/* User ID */)
          .set({
        'blood_group': _bloodGroupController.text,
        'address': _addressController.text,
        'last_donate_date': _lastDonateDateController.text,
        // Handle photo upload and add photo URL if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Basic user registration fields
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name')),
          TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone')),
          TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true),
          ElevatedButton(
            onPressed: _toggleDonorSection,
            child: Text(
                _isDonor ? 'Hide Donor Registration' : 'Donor Registration'),
          ),
          // Donor-specific fields, shown only when _isDonor is true
          if (_isDonor) ...[
            TextField(
                controller: _bloodGroupController,
                decoration: const InputDecoration(labelText: 'Blood Group')),
            TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address')),
            TextField(
                controller: _lastDonateDateController,
                decoration:
                    const InputDecoration(labelText: 'Last Donate Date')),
            // Implement photo upload logic here
          ],
          ElevatedButton(
            onPressed: _registerUser,
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
