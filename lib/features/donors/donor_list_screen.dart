import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/error_boundary.dart';
import './bloc/donor_bloc.dart';
import './models/donor_model.dart';
import './widgets/donor_card.dart';

class DonorListScreen extends StatelessWidget {
  const DonorListScreen({super.key});

  static List<String> bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];

  static List<String> districts = [
    'All',
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Khulna'
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonorBloc()..add(const LoadDonors()),
      child: ErrorBoundary(
        title: 'Error Loading Donors',
        onRetry: () => context.read<DonorBloc>().add(const LoadDonors()),
        child: Scaffold(
          body: BlocBuilder<DonorBloc, DonorState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildFilters(context, state),
                  Expanded(
                    child: _buildDonorList(context,state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, DonorState state) {
    String selectedBloodGroup = 'All';
    String selectedDistrict = 'All';

    if (state is DonorLoaded) {
      selectedBloodGroup = state.selectedBloodGroup;
      selectedDistrict = state.selectedDistrict;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                border: OutlineInputBorder(),
              ),
              items: bloodGroups.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                context.read<DonorBloc>().add(
                      LoadDonors(
                        bloodGroup: value,
                        district: selectedDistrict,
                      ),
                    );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: const InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(),
              ),
              items: districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                context.read<DonorBloc>().add(
                      LoadDonors(
                        bloodGroup: selectedBloodGroup,
                        district: value,
                      ),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorList(BuildContext context, DonorState state) {
    if (state is DonorLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DonorError) {
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
              onPressed: () => context.read<DonorBloc>().add(const LoadDonors()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is DonorLoaded) {
      if (state.donors.isEmpty) {
        return const Center(
          child: Text('No donors found matching your criteria.'),
        );
      }

      return ListView.builder(
        itemCount: state.donors.length,
        itemBuilder: (context, index) {
          final donor = state.donors[index];
          return DonorCard(
            donor: donor,
            onTap: () => _navigateToDonorDetail(context, donor),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  void _navigateToDonorDetail(BuildContext context, DonorModel donor) {
    context.push('/donor-detail/${donor.uid}');
  }
}
