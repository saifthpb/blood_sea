import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
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
    try {
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
        date = DateTime.parse(
            timestamp); // Assuming it's already a string representation of a date
      } else {
        return null;
      }
      return "${date.day}-${date.month}-${date.year}"; // Format: DD-MM-YYYY
    } catch (e) {
      print("Error formatting date: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child:
                CircularProgressIndicator()) // Show loading spinner if data isn't loaded
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
                Text(
                    "Last Donate Date: ${formatDate(lastDonateDate) ?? 'Not Available'}",
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
  }
}
