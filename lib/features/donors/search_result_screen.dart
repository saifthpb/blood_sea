import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchResultScreen extends StatefulWidget {
  final Map<String, dynamic>? searchParams;
  
  const SearchResultScreen({super.key, this.searchParams});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreen();
}

class _SearchResultScreen extends State<SearchResultScreen> {
  String? selectedBloodGroup; // Dropdown value for blood group
  String? selectedDistrict;  // Dropdown value for district

  List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  List<String> districts = ['Dhaka', 'Chittagong', 'Sylhet', 'Khulna']; // Add your districts here

  // Query results
  List<Map<String, dynamic>> filteredDonors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with passed search parameters
    if (widget.searchParams != null) {
      selectedBloodGroup = widget.searchParams!['bloodGroup'];
      selectedDistrict = _extractDistrictFromHospital(widget.searchParams!['hospital']);
      // Automatically search when screen loads
      filterDonors();
    }
  }

  String? _extractDistrictFromHospital(String? hospital) {
    if (hospital == null) return null;
    // Extract district from hospital name (e.g., "Delta Hospital, Mirpur-1, Dhaka" -> "Dhaka")
    if (hospital.contains('Dhaka')) return 'Dhaka';
    if (hospital.contains('Chittagong')) return 'Chittagong';
    if (hospital.contains('Sylhet')) return 'Sylhet';
    if (hospital.contains('Khulna')) return 'Khulna';
    return null;
  }

  // Function to filter donors
  Future<void> filterDonors() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      Query query = FirebaseFirestore.instance.collection('users')
          .where('userType', isEqualTo: 'donor')
          .where('isAvailable', isEqualTo: true);

      // Apply filters based on blood group and district
      if (selectedBloodGroup != null && selectedBloodGroup!.isNotEmpty) {
        query = query.where('bloodGroup', isEqualTo: selectedBloodGroup);
      }
      if (selectedDistrict != null && selectedDistrict!.isNotEmpty) {
        query = query.where('district', isEqualTo: selectedDistrict);
      }

      // Execute query and fetch results
      QuerySnapshot querySnapshot = await query.get();
      List<Map<String, dynamic>> donors = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'bloodGroup': data['bloodGroup'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
          'district': data['district'] ?? '',
          'thana': data['thana'] ?? '',
          'status': data['status'] ?? 'offline',
          'lastDonationDate': data['lastDonationDate'],
        };
      }).toList();

      setState(() {
        filteredDonors = donors; // Update the list
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Error filtering donors: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching donors: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Filter Donors', style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
            color: Colors.white
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blood Group Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Blood Group'),
              value: selectedBloodGroup,
              items: bloodGroups.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBloodGroup = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // District Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select District'),
              value: selectedDistrict,
              items: districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Filter Button
            ElevatedButton(
              onPressed: filterDonors,
              child: const Text('Filter Donors'),
            ),
            const SizedBox(height: 20),

            // Display Filtered Results
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredDonors.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No donors found',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              Text(
                                'Try adjusting your search criteria',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDonors.length,
                          itemBuilder: (context, index) {
                            final donor = filteredDonors[index];
                            final isOnline = donor['status'] == 'online';
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isOnline ? Colors.green : Colors.grey,
                                  child: Text(
                                    donor['bloodGroup'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  donor['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${donor['district']}, ${donor['thana']}'),
                                    Text(
                                      'Phone: ${donor['phoneNumber']}',
                                      style: const TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isOnline ? Icons.circle : Icons.circle_outlined,
                                      color: isOnline ? Colors.green : Colors.grey,
                                      size: 16,
                                    ),
                                    Text(
                                      isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isOnline ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Navigate to donor detail or show contact options
                                  _showContactOptions(context, donor);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context, Map<String, dynamic> donor) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact ${donor['name']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Call'),
                subtitle: Text(donor['phoneNumber']),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement phone call functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${donor['phoneNumber']}...'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.message, color: Colors.blue),
                title: const Text('Send Message'),
                subtitle: const Text('Request blood donation'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement messaging functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening message...'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.orange),
                title: const Text('Email'),
                subtitle: Text(donor['email']),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement email functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Emailing ${donor['email']}...'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
