import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blood_sea/loginActivity.dart';
import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/fragments/profileFragment.dart';
import 'package:blood_sea/fragments/searchFragment.dart';
import 'package:blood_sea/fragments/notificationFragment.dart';
import 'package:blood_sea/fragments/shareFragment.dart';
import 'package:blood_sea/fragments/privacyPolicyFragment.dart';
import 'package:blood_sea/fragments/contactFragment.dart';

class donorListFragment extends StatefulWidget {
  const donorListFragment({super.key});

  @override
  _DonorListFragment createState() => _DonorListFragment();
}

class _DonorListFragment extends State<donorListFragment> {
  String selectedBloodGroup = 'All';
  String selectedDistrict = 'All';
  DateTime threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

  List<String> bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  List<String> districts = ['All', 'Dhaka', 'Chittagong', 'Sylhet', 'Khulna'];

  int _selectedIndex = 0;

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => loginActivity()),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Donor List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const shareFragment()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const notificationFragment()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const searchFragment()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              accountName: Text("Saiful Sarwar"),
              accountEmail: Text("ssb2001@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/ssbf.png'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const homeFragment()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const profileFragment()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Search"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const searchFragment()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_emergency),
              title: const Text("Contact"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const contactFragment()));
              },
            ),
            const Divider(height: 2),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text("Privacy Policy"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const privacyPolicyFragment()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedBloodGroup,
                      onChanged: (value) {
                        setState(() {
                          selectedBloodGroup = value!;
                        });
                      },
                      items: bloodGroups.map((group) {
                        return DropdownMenuItem<String>(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedDistrict,
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value!;
                        });
                      },
                      items: districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('clients').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No donors found.'));
                  }

                  var donors = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var bloodGroupMatches = selectedBloodGroup == 'All' || data['bloodGroup'] == selectedBloodGroup;
                    var districtMatches = selectedDistrict == 'All' || data['district'] == selectedDistrict;
                    return bloodGroupMatches && districtMatches;
                  }).toList();

                  return ListView.builder(
                    itemCount: donors.length,
                    itemBuilder: (context, index) {
                      var donor = donors[index].data() as Map<String, dynamic>;
                      String name = donor['name'] ?? 'Unknown';
                      String phone = donor['phone'] ?? 'N/A';
                      String email = donor['email'] ?? 'N/A';
                      String bloodGroup = donor['bloodGroup'] ?? 'N/A';
                      String district = donor['district'] ?? 'N/A';
                      String thana = donor['thana'] ?? 'N/A';
                      DateTime? lastDonateDate = (donor['lastDonateDate'] as Timestamp?)?.toDate();
                      bool isAvailable = lastDonateDate == null || lastDonateDate.isBefore(threeMonthsAgo);

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Thana: $thana'),
                              Text('District: $district'),
                              Text('Blood Group: $bloodGroup'),
                              Text('Phone: $phone'),
                              Text('Email: $email'),
                            ],
                          ),
                          trailing: SingleChildScrollView(
                            reverse: true,
                          //trailing: Flexible(                    //earlier
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Text(
                                  isAvailable ? 'Available' : 'Unavailable',
                                  style: TextStyle(
                                    color: isAvailable ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: isAvailable ? () {} : null,
                                  child: const Text('Request Send',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white
                                  ),),
                                ),
                              ],
                            ),
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
      ),


      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const homeFragment()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const searchFragment()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const profileFragment()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const notificationFragment()));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        ],
      ),
    );
  }
}
