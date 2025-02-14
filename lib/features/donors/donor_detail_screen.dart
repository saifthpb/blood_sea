import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import './bloc/donor_detail_bloc.dart';
import './models/donor_model.dart';
import '../../shared/widgets/error_boundary.dart';

class DonorDetailScreen extends StatelessWidget {
  final String donorId;

  const DonorDetailScreen({
    super.key,
    required this.donorId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonorDetailBloc()..add(LoadDonorDetail(donorId)),
      child: ErrorBoundary(
        title: 'Error Loading Donor Details',
        onRetry: () => context.read<DonorDetailBloc>().add(LoadDonorDetail(donorId)),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Donor Details'),
            backgroundColor: Colors.redAccent,
          ),
          body: BlocBuilder<DonorDetailBloc, DonorDetailState>(
            builder: (context, state) {
              if (state is DonorDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DonorDetailError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<DonorDetailBloc>()
                            .add(LoadDonorDetail(donorId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is DonorDetailLoaded) {
                return _buildDonorDetail(context, state.donor);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDonorDetail(BuildContext context, DonorModel donor) {
    final bool isAvailable = donor.lastDonationDate == null ||
        donor.lastDonationDate!
            .isBefore(DateTime.now().subtract(const Duration(days: 90)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      donor.bloodGroup,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    donor.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAvailable ? 'Available' : 'Unavailable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Contact Information',
            children: [
              _buildInfoRow(Icons.phone, 'Phone', donor.phoneNumber),
              _buildInfoRow(Icons.email, 'Email', donor.email),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Location',
            children: [
              _buildInfoRow(Icons.location_city, 'District', donor.district),
              _buildInfoRow(Icons.place, 'Thana', donor.thana),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Donation History',
            children: [
              _buildInfoRow(
                Icons.calendar_today,
                'Last Donation',
                donor.lastDonationDate != null
                    ? _formatDate(donor.lastDonationDate!)
                    : 'No previous donation',
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isAvailable) ...[
            ElevatedButton.icon(
              onPressed: () => _showRequestDialog(context, donor),
              icon: const Icon(Icons.bloodtype),
              label: const Text('Request Blood Donation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ] else ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'This donor is currently unavailable for donation',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Donors must wait 3 months between donations',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
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
                  value,
                  style: const TextStyle(fontSize: 16),
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

  void _showRequestDialog(BuildContext context, DonorModel donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Blood Donation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to request blood from ${donor.name}?'),
            const SizedBox(height: 16),
            const Text(
              'This will send a notification to the donor.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement blood request logic
              context.pop();
              _showSuccessDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Sent'),
        content: const Text(
          'Your blood donation request has been sent. The donor will be notified.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.pop(); // Go back to donor list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
