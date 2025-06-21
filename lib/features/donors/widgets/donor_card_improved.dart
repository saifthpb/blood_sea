import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/donor_model.dart';

class DonorCard extends StatelessWidget {
  final DonorModel donor;
  final VoidCallback? onTap;

  const DonorCard({
    super.key,
    required this.donor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = _isAvailable();
    final String availabilityText = _getAvailabilityText();
    final Color availabilityColor = _getAvailabilityColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  _buildBloodGroupAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDonorInfo(),
                  ),
                  _buildAvailabilityStatus(availabilityText, availabilityColor),
                ],
              ),
              const SizedBox(height: 12),
              _buildActionButtons(context, isAvailable),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBloodGroupAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Center(
        child: Text(
          donor.bloodGroup,
          style: TextStyle(
            color: Colors.red.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDonorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          donor.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${donor.district}, ${donor.thana}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              donor.phoneNumber,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        if (donor.lastDonationDate != null) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.history, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Last donated: ${_formatDate(donor.lastDonationDate!)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAvailabilityStatus(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isAvailable) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _makePhoneCall(context),
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Call'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sendSMS(context),
            icon: const Icon(Icons.message, size: 16),
            label: const Text('SMS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isAvailable ? onTap : null,
            icon: const Icon(Icons.bloodtype, size: 16),
            label: const Text('Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable ? Colors.red : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  bool _isAvailable() {
    if (!donor.isAvailable) return false;
    if (donor.lastDonationDate == null) return true;
    
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    return donor.lastDonationDate!.isBefore(threeMonthsAgo);
  }

  String _getAvailabilityText() {
    if (!donor.isAvailable) return 'Unavailable';
    if (donor.lastDonationDate == null) return 'Available';
    
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    if (donor.lastDonationDate!.isBefore(threeMonthsAgo)) {
      return 'Available';
    } else {
      final daysUntilAvailable = 90 - DateTime.now().difference(donor.lastDonationDate!).inDays;
      return 'Available in $daysUntilAvailable days';
    }
  }

  Color _getAvailabilityColor() {
    if (!donor.isAvailable) return Colors.red;
    if (donor.lastDonationDate == null) return Colors.green;
    
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    return donor.lastDonationDate!.isBefore(threeMonthsAgo) 
        ? Colors.green 
        : Colors.orange;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: donor.phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar(context, 'Could not launch phone app');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error making phone call: $e');
    }
  }

  Future<void> _sendSMS(BuildContext context) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: donor.phoneNumber,
        queryParameters: {
          'body': 'Hi ${donor.name}, I need ${donor.bloodGroup} blood. Can you help?'
        },
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        _showErrorSnackBar(context, 'Could not launch SMS app');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error sending SMS: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
