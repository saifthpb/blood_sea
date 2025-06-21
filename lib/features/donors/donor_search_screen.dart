import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../notifications/services/blood_request_service.dart';

class DonorSearchScreen extends StatefulWidget {
  const DonorSearchScreen({super.key});

  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  final TextEditingController _dateController = TextEditingController();
  final BloodRequestService _bloodRequestService = BloodRequestService();
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
                                  onPressed: () => _sendBloodRequest(context, donor),
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

  Future<void> _sendBloodRequest(BuildContext context, Map<String, dynamic> donor) async {
    // Validate required fields
    if (_selectedBloodGroup == null) {
      _showErrorSnackBar(context, 'Please select a blood group');
      return;
    }

    if (_dateController.text.isEmpty) {
      _showErrorSnackBar(context, 'Please select a date');
      return;
    }

    // Show confirmation dialog with additional options
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) => _buildRequestDialog(context, donor),
    );

    if (result == null) return; // User cancelled

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sending blood request...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Send the blood request
      final success = await _bloodRequestService.sendBloodRequest(
        donorId: donor['id'],
        donorName: donor['name'],
        bloodGroup: _selectedBloodGroup!,
        patientLocation: _selectedHospital ?? 'Location not specified',
        requiredDate: _dateController.text,
        urgencyLevel: result['urgency'] ?? 'Normal',
        additionalMessage: result['message'],
      );

      // Hide loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        _showSuccessSnackBar(
          context,
          'Blood request sent to ${donor['name']} successfully!',
        );
      }
    } catch (e) {
      // Hide loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      _showErrorSnackBar(
        context,
        'Failed to send blood request: ${e.toString()}',
      );
    }
  }

  Widget _buildRequestDialog(BuildContext context, Map<String, dynamic> donor) {
    final TextEditingController messageController = TextEditingController();
    String selectedUrgency = 'Normal';

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.bloodtype, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Send Request to ${donor['name']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Request Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Blood Group: $_selectedBloodGroup'),
                      Text('Required Date: ${_dateController.text}'),
                      Text('Location: ${_selectedHospital ?? 'Not specified'}'),
                      Text('Donor: ${donor['name']}'),
                      Text('Contact: ${donor['phoneNumber']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Urgency Level
                const Text(
                  'Urgency Level',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedUrgency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Normal', 'Urgent', 'Emergency'].map((urgency) {
                    return DropdownMenuItem(
                      value: urgency,
                      child: Row(
                        children: [
                          Icon(
                            urgency == 'Emergency' ? Icons.warning : 
                            urgency == 'Urgent' ? Icons.priority_high : Icons.info,
                            color: urgency == 'Emergency' ? Colors.red : 
                                   urgency == 'Urgent' ? Colors.orange : Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(urgency),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUrgency = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Additional Message
                const Text(
                  'Additional Message (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Add any additional information about the patient or urgency...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop({
                  'urgency': selectedUrgency,
                  'message': messageController.text.trim().isEmpty 
                      ? null 
                      : messageController.text.trim(),
                });
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}