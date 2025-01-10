import 'package:blood_sea/fragments/notificationFragment.dart';
import 'package:blood_sea/fragments/privacyPolicyFragment.dart';
import 'package:blood_sea/fragments/shareFragment.dart';
import 'package:blood_sea/loginActivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For session management
import 'package:blood_sea/fragments/donorSearchFragment.dart';
import 'package:blood_sea/fragments/donorRegistration.dart';
import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/fragments/searchFragment.dart';
import 'package:blood_sea/fragments/contactFragment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class profileFragment extends StatefulWidget {
  const profileFragment({super.key});

  @override
  _ProfileFragment createState() => _ProfileFragment();
}

class _ProfileFragment extends State<profileFragment> {

  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FirebaseStorage _storage = FirebaseStorage.instance;
  //Map<String, dynamic>? userProfile;

  // Variables to store user data
  String? name;
  String? email;
  String? phone;
  String? bloodGroup;
  String? district;
  String? thana;
  String? photoUrl;
  String? lastDonateDate;
  bool isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userEmail = prefs.getString('email') ?? ''; // Replace with actual method to get logged-in user's email
    try{
      // Replace 'userID' with the UID of the logged-in user
      String userID = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
      await _firestore.collection('clients').doc(userID).get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'];
          email = userDoc['email'];
          phone = userDoc['phone'];
          bloodGroup = userDoc['bloodGroup'];
          district = userDoc['district'];
          thana = userDoc['thana'];
          photoUrl = userDoc['photoUrl'];
          lastDonateDate = userDoc['lastDonateDate'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("No user data found");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching user data: $e");
    }
  }


  // Helper method to format the date
// Helper method to format the date
  String? formatDate(dynamic timestamp) {
    if (timestamp == null) return null;
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp); // Assuming it's already a string representation of a date
      } else {
        return null;
      }
      return "${date.day}-${date.month}-${date.year}"; // Format: DD-MM-YYYY
    } catch (e) {
      print("Error formatting date: $e");
      return null;
    }
  }



  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn'); // Clear login session data

    // Navigate to the login screen after logging out
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
        title: const Text("Profile"),
        foregroundColor: Colors.white,
        elevation: 5,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const shareFragment()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => notificationFragment()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => searchFragment()),
              );
            },
          ),
        ],
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       UserAccountsDrawerHeader(
      //         decoration: BoxDecoration(color: Colors.redAccent),
      //         accountName: Text(userProfile != null ? userProfile!['name'] ?? 'Loading...' : 'Loading...'),
      //         accountEmail: Text(userProfile != null ? userProfile!['email'] ?? 'Loading...' : 'Loading...'),
      //         currentAccountPicture: CircleAvatar(
      //           backgroundImage: userProfile != null && userProfile!['photoUrl'] != null
      //               ? NetworkImage(userProfile!['photoUrl'])
      //               : AssetImage('assets/ssbf.png') as ImageProvider,
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.home),
      //         title: Text("Home"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(context, MaterialPageRoute(builder: (context) => homeFragment()));
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.person),
      //         title: Text("Profile"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(context, MaterialPageRoute(builder: (context) => profileFragment()));
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.search),
      //         title: Text("Search"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(context, MaterialPageRoute(builder: (context) => searchFragment()));
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.contact_emergency),
      //         title: Text("Contact"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(context, MaterialPageRoute(builder: (context) => contactFragment()));
      //         },
      //       ),
      //       Divider(height: 2),
      //       ListTile(
      //         leading: Icon(Icons.arrow_back),
      //         title: Text("Privacy Policy"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(context, MaterialPageRoute(builder: (context) => privacyPolicyFragment()));
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.logout),
      //         title: Text("Logout"),
      //         onTap: () {
      //           _logout();
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.arrow_back),
      //         title: Text("Back"),
      //         onTap: () {
      //           Navigator.pop(context);
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner if data isn't loaded
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl != null && photoUrl!.isNotEmpty)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(photoUrl!),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            const SizedBox(height: 8),
            Text("Name: ${name ?? 'Not Available'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Email: ${email ?? 'Not Available'}",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 8),
            Text("Phone: ${phone ?? 'Not Available'}",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 8),
            Text("Thana: ${thana ?? 'Not Available'}",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 8),
            Text("District: ${district ?? 'Not Available'}",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 8),
            Text("Blood Group: ${bloodGroup ?? 'Not Available'}",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 8),
            Text("Photo: ${photoUrl ?? 'Not Available'}",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 8),
            Text("Last Donate Date: ${formatDate(lastDonateDate) ?? 'Not Available'}",
                style: const TextStyle(fontSize: 18)),


          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const donorRegistration()),
          );


        },
        backgroundColor: Colors.red,
        tooltip: "Register as Donor",
        child: const Text(
          "+",
          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
