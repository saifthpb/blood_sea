import 'package:flutter/material.dart';
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
    final bool isAvailable = donor.lastDonationDate == null ||
        donor.lastDonationDate!
            .isBefore(DateTime.now().subtract(const Duration(days: 90)));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: Text(
            donor.bloodGroup,
            style: TextStyle(
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(donor.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${donor.district}, ${donor.thana}'),
            Text(donor.phoneNumber),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isAvailable ? 'Available' : 'Unavailable',
              style: TextStyle(
                color: isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: isAvailable ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }
}
