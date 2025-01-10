import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:blood_sea/features/home/home.dart';
import 'package:blood_sea/features/notifications/notifications.dart';
import 'package:blood_sea/features/privacy_policy/privacy_policy.dart';
import 'package:blood_sea/features/share/share.dart';
import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For session management
import 'package:blood_sea/features/donors/donor_search_screen.dart';
//import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/features/profile/profile.dart';
import 'package:blood_sea/features/donors/search.dart';
import 'package:blood_sea/features/contact/contact_screen.dart';
import 'package:blood_sea/features/donors/donor_list_screen.dart';
import 'donor_registration_screen.dart';

class DonorRegistrationScreen extends StatefulWidget {
  const DonorRegistrationScreen({super.key});

  @override
  _DonorRegistrationScreenState createState() => _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _selectedBloodGroup;
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _thanaController = TextEditingController();
final TextEditingController _lastDonateDateController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }



  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('clients').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'];
            _userEmail = userDoc['email'];
            _userPhone = userDoc['phone'];
          });
        } else {
          throw "User data does not exist in Firestore.";
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        String filePath = 'donor_images/${user.uid}.jpg';
        TaskSnapshot uploadTask = await _storage.ref(filePath).putFile(image);
        return await uploadTask.ref.getDownloadURL();
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
    return null;
  }

  @override
  void dispose() {
    _lastDonateDateController.dispose();
    super.dispose();
  }

  Future<void> _submitDonorData() async {
    if (_selectedBloodGroup == null || _districtController.text.isEmpty || _thanaController.text.isEmpty || _lastDonateDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields!")),
      );
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user != null) {
        String? photoUrl;
        if (_selectedImage != null) {
          photoUrl = await _uploadImage(_selectedImage!);
        }

        // Convert the 'lastDonateDate' from string to Timestamp - added these lines 26 december 24, but does not work
         DateTime lastDonateDate = DateTime.parse(_lastDonateDateController.text.trim());
        Timestamp lastDonateTimestamp = Timestamp.fromDate(lastDonateDate);

        //lastDonate Date


        await _firestore.collection('clients').doc(user.uid).update({
          'name': _userName,
          'email': _userEmail,
          'phone': _userPhone,
          'bloodGroup': _selectedBloodGroup,
          'district': _districtController.text.trim(),
          'thana': _thanaController.text.trim(),
          'photoUrl': photoUrl,
          //'lastDonateDate': lastDonateTimestamp, // Storing as Timestamp
          'registeredAt': FieldValue.serverTimestamp(),
        });

        // Clear the form fields
        setState(() {
          _selectedBloodGroup = null;
          _districtController.clear();
          _thanaController.clear();
          _lastDonateDateController.clear();
          _selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Donor registration successful!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting data: $e")),
      );
    }
  }

  // Future<void> _pickImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       _selectedImage = File(image.path);
  //     });
  //   }
  // }

  Future<void> _pickImage() async {
    if (_isRunningOnEmulator()) {
      setState(() {
        _selectedImage = File('assets/mock_image.jpg');
      });
    } else {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  bool _isRunningOnEmulator() {
    // Detect if the app is running on an emulator
    return !kReleaseMode && !kIsWeb && Platform.isAndroid;
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 60),
      backgroundColor: Colors.green,
      textStyle: const TextStyle(fontSize: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Donor Registration"),
          backgroundColor: Colors.red,
        ),
        body: _userName == null || _userEmail == null || _userPhone == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(text: _userName),
                readOnly: true,
                decoration: const InputDecoration(labelText: "Fullname"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: _userEmail),
                readOnly: true,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: _userPhone),
                readOnly: true,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
                decoration: const InputDecoration(labelText: "Blood Group"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: "District"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _thanaController,
                decoration: const InputDecoration(labelText: "Thana/Upazila"),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              TextField(
                  controller: _lastDonateDateController, // Rename controller to suit the field, e.g., _lastDonateDateController

                readOnly: true, // Prevent manual input
                decoration: const InputDecoration(
                  labelText: "Last Donate Date",
                  suffixIcon: Icon(Icons.calendar_today), // Calendar icon for better UX
                ),
                onTap: () async {
                  // Display the date picker
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), // Set the current date as the default
                    firstDate: DateTime(2000), // Earliest date
                    lastDate: DateTime(2100), // Latest date
                  );

                  if (pickedDate != null) {
                    // Format the picked date to a readable string
                    String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    // Update the controller's text with the selected date
                    _lastDonateDateController.text = formattedDate;
                  }
                },
              ),


              const SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150, width: 150)
                  : ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text("Upload Photo"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitDonorData,
                style: buttonStyle,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),

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
                  MaterialPageRoute(builder: (context) => const homeFragment()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const searchFragment()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const profileFragment()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const notificationFragment()),
                );
                break;
            }
          },
          items: const [
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
      ),
    );
  }
}

