import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/error_boundary.dart';
import './bloc/donor_bloc.dart';
import './models/donor_model.dart';
import './widgets/donor_card.dart';

class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  static const List<String> bloodGroups = [
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

  // Complete list of Bangladesh districts
  static const List<String> districts = [
    'All',
    'Bagerhat', 'Bandarban', 'Barguna', 'Barishal', 'Bhola', 'Bogura',
    'Brahmanbaria', 'Chandpur', 'Chattogram', 'Chuadanga', 'Comilla',
    'Cox\'s Bazar', 'Cumilla', 'Dhaka', 'Dinajpur', 'Faridpur', 'Feni',
    'Gaibandha', 'Gazipur', 'Gopalganj', 'Habiganj', 'Jamalpur', 'Jashore',
    'Jhalokati', 'Jhenaidah', 'Joypurhat', 'Khagrachhari', 'Khulna',
    'Kishoreganj', 'Kurigram', 'Kushtia', 'Lakshmipur', 'Lalmonirhat',
    'Madaripur', 'Magura', 'Manikganj', 'Meherpur', 'Moulvibazar',
    'Munshiganj', 'Mymensingh', 'Naogaon', 'Narail', 'Narayanganj',
    'Narsingdi', 'Natore', 'Netrokona', 'Nilphamari', 'Noakhali',
    'Pabna', 'Panchagarh', 'Patuakhali', 'Pirojpur', 'Rajbari',
    'Rajshahi', 'Rangamati', 'Rangpur', 'Satkhira', 'Shariatpur',
    'Sherpur', 'Sirajganj', 'Sunamganj', 'Sylhet', 'Tangail',
    'Thakurgaon'
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonorBloc()..add(const LoadDonors()),
      child: ErrorBoundary(
        title: 'Error Loading Donors',
        onRetry: () => context.read<DonorBloc>().add(const LoadDonors()),
        child: Scaffold(
          body: Column(
            children: [
              _buildSearchBar(),
              _buildFilters(),
              _buildDonorCountInfo(),
              Expanded(
                child: _buildDonorList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search donors by name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _applyFilters();
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return BlocBuilder<DonorBloc, DonorState>(
      builder: (context, state) {
        String selectedBloodGroup = 'All';
        String selectedDistrict = 'All';

        if (state is DonorLoaded) {
          selectedBloodGroup = state.selectedBloodGroup;
          selectedDistrict = state.selectedDistrict;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: bloodGroups.map((group) {
                    return DropdownMenuItem(
                      value: group,
                      child: Text(group),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _applyFilters(bloodGroup: value);
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _applyFilters(district: value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDonorCountInfo() {
    return BlocBuilder<DonorBloc, DonorState>(
      builder: (context, state) {
        if (state is DonorLoaded) {
          final filteredDonors = _getFilteredDonors(state.donors);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredDonors.length} donors found',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton.icon(
                  onPressed: () => _applyFilters(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDonorList() {
    return BlocBuilder<DonorBloc, DonorState>(
      builder: (context, state) {
        if (state is DonorLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DonorError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading donors',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<DonorBloc>().add(const LoadDonors()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is DonorLoaded) {
          final filteredDonors = _getFilteredDonors(state.donors);
          
          if (filteredDonors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No donors found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try adjusting your search criteria',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DonorBloc>().add(const LoadDonors());
            },
            child: ListView.builder(
              itemCount: filteredDonors.length,
              itemBuilder: (context, index) {
                final donor = filteredDonors[index];
                return DonorCard(
                  donor: donor,
                  onTap: () => _navigateToDonorDetail(context, donor),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<DonorModel> _getFilteredDonors(List<DonorModel> donors) {
    if (_searchQuery.isEmpty) return donors;
    
    return donors.where((donor) {
      return donor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             donor.phoneNumber.contains(_searchQuery);
    }).toList();
  }

  void _applyFilters({String? bloodGroup, String? district}) {
    final currentState = context.read<DonorBloc>().state;
    String currentBloodGroup = 'All';
    String currentDistrict = 'All';

    if (currentState is DonorLoaded) {
      currentBloodGroup = currentState.selectedBloodGroup;
      currentDistrict = currentState.selectedDistrict;
    }

    context.read<DonorBloc>().add(
      LoadDonors(
        bloodGroup: bloodGroup ?? currentBloodGroup,
        district: district ?? currentDistrict,
      ),
    );
  }

  void _navigateToDonorDetail(BuildContext context, DonorModel donor) {
    try {
      context.push('/donor-detail/${donor.uid}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error navigating to donor details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
