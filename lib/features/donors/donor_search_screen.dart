import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorSearchScreen extends StatefulWidget {
  const DonorSearchScreen({super.key});

  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  final TextEditingController _dateController = TextEditingController();
  String? _selectedBloodGroup;
  String? _selectedHospital;
  List<Map<String, dynamic>> _filteredDonors = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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

  Future<void> _searchDonors() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    
    try {
      String? district = _extractDistrictFromHospital(_selectedHospital);
      
      Query query = FirebaseFirestore.instance.collection('users')
          .where('userType', isEqualTo: 'donor')
          .where('isAvailable', isEqualTo: true);

      // Apply blood group filter
      if (_selectedBloodGroup != null) {
        query = query.where('bloodGroup', isEqualTo: _selectedBloodGroup);
      }

      // Apply district filter if we can extract it from hospital
      if (district != null) {
        query = query.where('district', isEqualTo: district);
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
        _filteredDonors = donors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error searching donors: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching donors: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final List<String> hospitalList = [
    "Delta Hospital, Mirpur-1, Dhaka",
    "Azmol Hospital, Mirpur-10, Dhaka",
    "Alok Hospital, Mirpur-2, Dhaka",
    "Modern Hospital, Dhanmondi, Dhaka",
    "Square Hospital, Panthapath, Dhaka",
    "Popular Hospital, Shyamoli, Dhaka",
    "Ibn Sina Hospital, Dhanmondi, Dhaka",
    "United Hospital, Gulshan, Dhaka",
    "Apollo Hospital, Bashundhara, Dhaka",
    "LabAid Hospital, Dhanmondi, Dhaka",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Request'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Welcome to Donors Area"),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(5),
                child: DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Blood Group",
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  items: [
                    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                  ].map((bloodGroup) {
                    return DropdownMenuItem(
                      value: bloodGroup,
                      child: Text(bloodGroup),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodGroup = value;
                    });
                    if (kDebugMode) {
                      print("Selected Blood Group: $value");
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a blood group';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Date of blood requirement",
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
        
                    if (pickedDate != null) {
                      String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      _dateController.text = formattedDate;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return hospitalList.where((hospital) =>
                        hospital.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController textController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Patient's Location",
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        suffixIcon: Icon(Icons.location_on),
                      ),
                    );
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _selectedHospital = selection;
                    });
                    if (kDebugMode) {
                      print("Selected Hospital: $selection");
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedBloodGroup == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a blood group'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (_dateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a date'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (kDebugMode) {
                      print("Show Donor List button clicked");
                      print("Blood Group: $_selectedBloodGroup");
                      print("Date: ${_dateController.text}");
                      print("Hospital: $_selectedHospital");
                    }
                    
                    // Search for donors and show results below
                    _searchDonors();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black54,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.redAccent, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      child: const Text(
                        "Show Donor List",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Show search results or message
              if (_hasSearched) ...[
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_filteredDonors.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Column(
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
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Found ${_filteredDonors.length} donor(s)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredDonors.length,
                          itemBuilder: (context, index) {
                            final donor = _filteredDonors[index];
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
                                      fontSize: 12,
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
                                trailing: ElevatedButton(
                                  onPressed: () => _showContactOptions(context, donor),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    minimumSize: const Size(80, 30),
                                  ),
                                  child: const Text(
                                    "Send Request",
                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ] else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.bloodtype, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Ready to find blood donors',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Fill the form above and click "Show Donor List"',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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