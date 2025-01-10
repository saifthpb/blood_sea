import 'package:blood_sea/features/notifications/notifications.dart';
import 'package:blood_sea/features/privacy_policy/privacy_policy.dart';
import 'package:blood_sea/features/share/share.dart';
import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For session management
import 'package:blood_sea/features/donors/donor_search_screen.dart';
import 'package:blood_sea/features/home/home.dart';
import 'package:blood_sea/features/profile/profile.dart';
import 'package:blood_sea/features/donors/search.dart';
import 'package:blood_sea/features/contact/contact_screen.dart';
import 'package:blood_sea/features/donors/donor_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/donor_registration_screen.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({super.key});

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

  // Function to filter donors
  Future<void> filterDonors() async {
    try {
      Query query = FirebaseFirestore.instance.collection('clients');

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
        return {
          'name': doc['name'],
          'bloodGroup': doc['bloodGroup'],
          'email': doc['email'],
          'phone': doc['phone'],
          'district': doc['district'],
          'thana': doc['thana'],
        };
      }).toList();

      setState(() {
        filteredDonors = donors; // Update the list
      });
    } catch (e) {
      print('Error filtering donors: $e');
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
              child: ListView.builder(
                itemCount: filteredDonors.length,
                itemBuilder: (context, index) {
                  final donor = filteredDonors[index];
                  return Card(
                    child: ListTile(
                      title: Text('${donor['name']} (${donor['bloodGroup']})'),
                      subtitle: Text('${donor['district']}, ${donor['thana']}'),
                      trailing: Text(donor['phone']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items:const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        ],
      ),
    );
  }
}
