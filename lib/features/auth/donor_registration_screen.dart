import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class DonorRegistrationScreen extends StatefulWidget {
  const DonorRegistrationScreen({super.key});

  @override
  State<DonorRegistrationScreen> createState() =>
      _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _selectedBloodGroup;
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _thanaController = TextEditingController();
  final TextEditingController _lastDonateDateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'];
            _userEmail = userDoc['email'];
            _userPhone = userDoc['phoneNumber']; // Note: field name is phoneNumber, not phone
          });
        } else {
          throw "User data does not exist in Firestore.";
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
      // ignore: use_build_context_synchronously
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
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
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
    if (_selectedBloodGroup == null ||
        _districtController.text.isEmpty ||
        _thanaController.text.isEmpty ||
        _lastDonateDateController.text.isEmpty) {
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

        // Parse the date from dd/MM/yyyy format and convert to Timestamp
        List<String> dateParts = _lastDonateDateController.text.trim().split('/');
        DateTime lastDonateDate = DateTime(
          int.parse(dateParts[2]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[0]), // day
        );
        
        await _firestore.collection('users').doc(user.uid).update({
          'name': _userName,
          'email': _userEmail,
          'phoneNumber': _userPhone,
          'bloodGroup': _selectedBloodGroup,
          'district': _districtController.text.trim(),
          'thana': _thanaController.text.trim(),
          'photoUrl': photoUrl,
          'lastDonationDate': Timestamp.fromDate(lastDonateDate),
          'userType': 'donor',
          'isDonor': true,
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

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Donor registration successful!")),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Registration'),
        backgroundColor: Colors.redAccent,
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
                      .map((group) =>
                          DropdownMenuItem(value: group, child: Text(group)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedBloodGroup = value),
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
                  controller:
                      _lastDonateDateController, // Rename controller to suit the field, e.g., _lastDonateDateController

                  readOnly: true, // Prevent manual input
                  decoration: const InputDecoration(
                    labelText: "Last Donate Date",
                    suffixIcon: Icon(
                        Icons.calendar_today), // Calendar icon for better UX
                  ),
                  onTap: () async {
                    // Display the date picker
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.now(), // Set the current date as the default
                      firstDate: DateTime(2000), // Earliest date
                      lastDate: DateTime(2100), // Latest date
                    );

                    if (pickedDate != null) {
                      // Format the picked date to a readable string
                      String formattedDate =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
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
    );
  }
}
