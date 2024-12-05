// import 'package:blood_sea/loginActivity.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// void main(){
//   runApp(const donorRegistration());
// }
// class donorRegistration extends StatefulWidget {
//   //const donorRegistration({super.key});
//   const donorRegistration({Key? key}) : super(key: key);
//
//   @override
//   _donorRegistrationState createState() => _donorRegistrationState();
// }
//
// class _donorRegistrationState extends State<donorRegistration> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   String? _userName;
//   String? _userEmail;
//   String? _userPhone;
//   String? _selectedBloodGroup;
//   final TextEditingController _districtController = TextEditingController();
//   final TextEditingController _thanaController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }
//
//   Future<void> _fetchUserData() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         final userDoc = await _firestore.collection('clients')
//             .doc(user.uid)
//             .get();
//         if (!userDoc.exists) {
//           //   print("User document not found in Firestore.");
//           //   throw "User data does not exist in Firestore.";
//           // }
//
//           setState(() {
//             _userName = userDoc['name'];
//             _userEmail = userDoc['email'];
//             _userPhone = userDoc['phone'];
//           });
//         } else{
//           throw "User data does not exist in Firestore.";
//         }
//       }
//     } catch (e) {
//       print("Error fetching user data: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error fetching user data: $e")),
//       );
//     }
//   }
// //changed will be needed by 5 dec 2024 according to chatGPT
//   Future<String?> _uploadImage(File image) async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         String filePath = 'donor_images/${user.uid}.jpg';
//         TaskSnapshot uploadTask = await _storage.ref(filePath).putFile(image);
//         return await uploadTask.ref.getDownloadURL();
//       }
//     } catch (e) {
//       print("Error uploading image: $e");
//       return null;
//     }
//     return null;
//   }
//
//   Future<void> _submitDonorData() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         await _firestore.collection('clients').doc(user.uid).update({
//           'name': _userName,
//           'email': _userEmail,
//           'phone': _userPhone,
//           'bloodGroup': _selectedBloodGroup,
//           'district': _districtController.text.trim(),
//           'thana': _thanaController.text.trim(),
//           'photoUrl': _selectedImage != null ? _selectedImage!.path : null,
//           'registeredAt': FieldValue.serverTimestamp(),
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Donor registration successful!")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error submitting data: $e")),
//       );
//     }
//   }
//
//   // void MySnackBar(String message, BuildContext context){
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(content: Text(message)),
//   //   );
//   // }
//
//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _selectedImage = File(image.path);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ButtonStyle buttonStyle = ElevatedButton.styleFrom(
//         minimumSize: Size(double.infinity, 60),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         textStyle: TextStyle(fontSize: 20),
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(5)
//         )
//
//     );
//
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primaryColor: Colors.green),
//       darkTheme: ThemeData(primaryColor: Colors.cyan),
//       home: Scaffold(
//         appBar: AppBar(
//           toolbarHeight: 60,
//           title: const Text("Blood Donation App", style: TextStyle(color: Colors.yellow),),
//           backgroundColor: Colors.red,
//           titleSpacing: 10,
//           elevation: 1,
//           // actions: [
//           //   IconButton(onPressed: (){
//           //     //MySnackBar("I am Home", context);
//           //   },
//           //       icon: const Icon(Icons.home, color: Colors.white,)),
//           //   IconButton(onPressed: (){MySnackBar("I am Home", context);}, icon: const Icon(Icons.facebook, color: Colors.white,)),
//           //   IconButton(onPressed: (){MySnackBar("I am Home", context);}, icon: const Icon(Icons.search), color: Colors.white,),
//           //   IconButton(onPressed: (){MySnackBar("I am Home", context);}, icon: const Icon(Icons.settings, color: Colors.white,)),
//           // ],
//         ),
//
//         // bottomNavigationBar: BottomNavigationBar  (
//         // code here
//         // ),
//                body: _userName == null || _userEmail == null || _userPhone == null
//                ? Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                  padding: const EdgeInsets.all(10.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text("Donor Registration",
//                 style: TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18
//                 ),),
//                 SizedBox(height: 5,),
//
//                 TextField(
//                   controller: TextEditingController(text: _userName),
//                   readOnly: true,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: "Fullname",
//                       contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   ),
//
//                 ),
//               SizedBox(height:10),
//
//                 TextField(
//                   controller: TextEditingController(text: _userEmail),
//                   readOnly: true,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: "Email Account",
//                     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   ),
//
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: TextEditingController(text: _userPhone),
//                   readOnly: true,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: "Mobile Number",
//                     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   ),
//
//                 ),
//                 SizedBox(height: 10),
//
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: "Select Blood Group",
//                     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   ),
//                   items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
//                       .map((bloodGroup) => DropdownMenuItem(
//                     value: bloodGroup,
//                     child: Text(bloodGroup),
//                   ))
//                       .toList(),
//                   onChanged: (value) => setState(() => _selectedBloodGroup = value),
//                   validator: (value) {
//                     if (value == null) {
//                       return "Please select a blood group.";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: _districtController,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: "District",
//                     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//
//                 TextField(
//                   controller: _thanaController,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: "Thana/Upazila/City",
//                     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//
//                 _selectedImage != null
//                     ? Image.file(
//                   _selectedImage!,
//                   height: 150,
//                   width: 150,
//                   fit: BoxFit.cover,
//                 )
//                     : ElevatedButton.icon(
//                   onPressed: _pickImage,
//                   icon: Icon(Icons.upload),
//                   label: Text("Upload Photo"),
//                   style: buttonStyle,
//                 ),
//                 SizedBox(height: 10),
//
//                 ElevatedButton(
//                   onPressed: _submitDonorData,
//                   child: Text("Submit"),
//                   style: buttonStyle,
//                 ),
//
//                 GestureDetector(
//                   onTap: (){
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=> loginActivity()),);
//                   },
//                   child: Text("Registered Member !! Please Sign In"),
//                 )
//               ],
//             ),
//           ),
//         ),
//
//       );
//
//   }
// }

//new codes
import 'package:blood_sea/loginActivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

void main() {
  runApp(const donorRegistration());
}

class donorRegistration extends StatefulWidget {
  const donorRegistration({Key? key}) : super(key: key);

  @override
  _donorRegistrationState createState() => _donorRegistrationState();
}

class _donorRegistrationState extends State<donorRegistration> {
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

  Future<void> _submitDonorData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        String? photoUrl;
        if (_selectedImage != null) {
          photoUrl = await _uploadImage(_selectedImage!);
        }

        await _firestore.collection('clients').doc(user.uid).update({
          'name': _userName,
          'email': _userEmail,
          'phone': _userPhone,
          'bloodGroup': _selectedBloodGroup,
          'district': _districtController.text.trim(),
          'thana': _thanaController.text.trim(),
          'photoUrl': photoUrl,
          'lastDonateDate': _lastDonateDateController.text.trim(),
          'registeredAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Donor registration successful!")),
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
      minimumSize: Size(double.infinity, 60),
      backgroundColor: Colors.green,
      textStyle: TextStyle(fontSize: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Donor Registration"),
          backgroundColor: Colors.red,
        ),
        body: _userName == null || _userEmail == null || _userPhone == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(text: _userName),
                readOnly: true,
                decoration: InputDecoration(labelText: "Fullname"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: _userEmail),
                readOnly: true,
                decoration: InputDecoration(labelText: "Email"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: _userPhone),
                readOnly: true,
                decoration: InputDecoration(labelText: "Phone"),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
                decoration: InputDecoration(labelText: "Blood Group"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(labelText: "District"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _thanaController,
                decoration: InputDecoration(labelText: "Thana/Upazila"),
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              TextField(
                controller: _lastDonateDateController, // Rename controller to suit the field, e.g., _lastDonateDateController
                readOnly: true, // Prevent manual input
                decoration: InputDecoration(
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


              SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150, width: 150)
                  : ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.upload),
                label: Text("Upload Photo"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitDonorData,
                child: Text("Submit"),
                style: buttonStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

