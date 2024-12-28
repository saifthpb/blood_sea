import 'package:blood_sea/fragments/notificationFragment.dart';
import 'package:blood_sea/fragments/privacyPolicyFragment.dart';
import 'package:blood_sea/fragments/shareFragment.dart';
import 'package:blood_sea/loginActivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For session management
import 'package:blood_sea/fragments/donorSearchFragment.dart';
import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/fragments/profileFragment.dart';
import 'package:blood_sea/fragments/searchFragment.dart';
import 'package:blood_sea/fragments/contactFragment.dart';
import 'package:blood_sea/fragments/donorListFragment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'donorRegistration.dart';

class searchResultFragment extends StatefulWidget {
  @override
  _searchResultFragment createState() => _searchResultFragment();
}

class _searchResultFragment extends State<searchResultFragment> {
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
        title: Text('Filter Donors', style: TextStyle(
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
              decoration: InputDecoration(labelText: 'Select Blood Group'),
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
            SizedBox(height: 16),

            // District Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select District'),
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
            SizedBox(height: 16),

            // Filter Button
            ElevatedButton(
              onPressed: filterDonors,
              child: Text('Filter Donors'),
            ),
            SizedBox(height: 20),

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
        items:[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        ],
      ),
    );
  }
}
