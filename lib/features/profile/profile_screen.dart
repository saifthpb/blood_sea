import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/models/user_model.dart';
import 'bloc/profile_bloc.dart';
import 'widgets/edit_profile_dialog.dart';

// lib/features/profile/screens/profile_screen.dart
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.redAccent,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'logout':
                    final shouldLogout = await _showLogoutDialog(context);
                    if (shouldLogout && context.mounted) {
                      try {
                        context.read<AuthBloc>().add(LogoutRequested());
                        context.go('/login'); // Navigate to login screen
                      } catch (e) {
                        // Handle case where AuthBloc is not available
                        print('Error accessing AuthBloc: $e');
                        context.go('/login');
                      }
                    }
                    break;
                  case 'edit':
                    // Handle edit profile
                    if (context.mounted) {
                      final state = context.read<ProfileBloc>().state;
                      if (state is ProfileLoaded) {
                        _showEditProfileDialog(context, state.user);
                      }
                    }
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<ProfileBloc>().add(LoadProfile()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded) {
              return _buildProfileContent(context, state.user);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(LoadProfile());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      user.name?.substring(0, 1).toUpperCase() ??
                          user.email.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    user.name ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              title: 'Personal Information',
              icon: Icons.person,
              children: [
                _buildInfoRow(
                  label: 'Phone',
                  value: user.phoneNumber,
                  icon: Icons.phone,
                ),
                if (user.bloodGroup != null)
                  _buildInfoRow(
                    label: 'Blood Group',
                    value: user.bloodGroup!,
                    icon: Icons.bloodtype,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Location',
              icon: Icons.location_on,
              children: [
                _buildInfoRow(
                  label: 'District',
                  value: user.district,
                  icon: Icons.location_city,
                ),
                _buildInfoRow(
                  label: 'Thana',
                  value: user.thana,
                  icon: Icons.place,
                ),
              ],
            ),
            if (user.lastDonationDate != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Donation History',
                icon: Icons.history,
                children: [
                  _buildInfoRow(
                    label: 'Last Donation',
                    value: _formatDate(user.lastDonationDate!),
                    icon: Icons.calendar_today,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String? value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value ?? 'Not provided',
                  style: TextStyle(
                    fontSize: 16,
                    color: value != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    // Implement edit profile dialog
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(user: user),
    );
  }
}
