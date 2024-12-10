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
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart';

class donorListFragment extends StatefulWidget {
  @override
  _DonorListFragment createState() => _DonorListFragment();
// Sample data for demonstration
}

class _DonorListFragment extends State<donorListFragment> {

  String selectedBloodGroup = 'All'; // Default filter
  String selectedDistrict = 'All'; // Default filter
  String selectedThana = 'All'; // Default filter
  DateTime threeMonthsAgo = DateTime.now().subtract(Duration(days: 90));
  // Filter options for blood groups and districts
  List<String> bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  List<String> districts = ['All', 'Dhaka', 'Chittagong', 'Sylhet', 'Khulna']; // Add districts as needed


  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  // Logout functionality using SharedPreferences (or Firebase if preferred)
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn'); // Clear login session data

    // Navigate to the login screen after logging out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context)=> loginActivity()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text("Donor List"),
        foregroundColor: Colors.white,
        elevation: 5,
        titleSpacing: 0,
        actions: [

          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Handle settings tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>shareFragment()));
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>notificationFragment()));
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle settings tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>searchFragment()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              accountName: Text("Saiful Sarwar"),
              accountEmail: Text("ssb2001@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/ssbf.png'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> homeFragment()),);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile fragment
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => profileFragment()),);
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text("Search"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to search fragment
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => searchFragment()),);
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_emergency),
              title: Text("Contact"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to contact page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => contactFragment()),);
              },
            ),
            Divider(height: 2,),

            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text("Privacy Policy"),
              onTap: () {
                //Navigator.pop(context);
                Navigator.pop(context);
                // Navigate to contact page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => privacyPolicyFragment()),);
              },
            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                // Implement logout functionality
                _logout();
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text("Back"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      // Body Start
      body: Column(
        children: [
          // Filters for blood group and district
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedBloodGroup, // Selected blood group filter
                    onChanged: (value) {
                      setState(() {
                        selectedBloodGroup = value!;
                      });
                    },
                    items: bloodGroups.map((group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group), // Blood group name
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedDistrict, // Selected district filter
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value!;
                      });
                    },
                    items: districts.map((district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district), // District name
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Donor List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('clients').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Show loading indicator
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No donors found.')); // Show no data message
                }

                // Filter donors based on selected criteria
                var donors = snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return doc.data() as Map<String, dynamic>;
                  // var bloodGroupMatches = selectedBloodGroup == 'All' || data['bloodGroup'] == selectedBloodGroup;
                  // var districtMatches = selectedDistrict == 'All' || data['district'] == selectedDistrict;
                  // return bloodGroupMatches && districtMatches;
                }).toList();

                return ListView.builder(
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    var donor = donors[index];
                    return ListTile(
                      title: Text(donor['name'] ?? 'Unknown'),
                      subtitle: Text('Blood Group: ${donor['bloodGroup'] ?? 'N/A'}'),
                    );

                    // Extract donor details
                    String name = donor['name'] ?? 'Unknown'; // For name
                    String phone = donor['phone'] ?? 'N/A'; // For phone
                    String email = donor['email'] ?? 'N/A'; // For email
                    String bloodGroup = donor['bloodGroup'] ?? 'N/A'; // For blood group
                    String district = donor['district'] ?? 'N/A'; // For district
                    String thana = donor['thana'] ?? 'N/A'; // For thana
                    DateTime? lastDonateDate = (donor['lastDonateDate'] as Timestamp?)?.toDate(); // For last donate date
                    bool isAvailable = lastDonateDate == null || lastDonateDate.isBefore(threeMonthsAgo);

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(name), // Donor name
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Thana: $thana'), // Thana
                            Text('District: $district'), // District
                            Text('Blood Group: $bloodGroup'), // Blood Group
                            Text('Phone: $phone'), // Phone
                            Text('Email: $email'), // Email
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isAvailable ? 'Available' : 'Unavailable', // Availability status
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            ElevatedButton(
                              onPressed: isAvailable
                                  ? () {
                                // Implement "Request Send" logic here
                              }
                                  : null,
                              child: Text('Request Send'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Body End



      //bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white, // Color for selected item
        unselectedItemColor: Colors.white, // Color for unselected items
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate to the respective pages based on the index
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => homeFragment()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => searchFragment()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => profileFragment()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => notificationFragment()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
        ],
      ),
    );
  }
}
