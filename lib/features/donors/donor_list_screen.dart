import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  State<DonorListScreen> createState() => _DonorListScreen();
}

class _DonorListScreen extends State<DonorListScreen> {
  String selectedBloodGroup = 'All';
  String selectedDistrict = 'All';
  DateTime threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

  List<String> bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  List<String> districts = ['All', 'Dhaka', 'Chittagong', 'Sylhet', 'Khulna'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              stream:
                  FirebaseFirestore.instance.collection('clients').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No donors found.'));
                }

                var donors = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var bloodGroupMatches = selectedBloodGroup == 'All' ||
                      data['bloodGroup'] == selectedBloodGroup;
                  var districtMatches = selectedDistrict == 'All' ||
                      data['district'] == selectedDistrict;
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
                    DateTime? lastDonateDate =
                        (donor['lastDonateDate'] as Timestamp?)?.toDate();
                    bool isAvailable = lastDonateDate == null ||
                        lastDonateDate.isBefore(threeMonthsAgo);

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
                                  color:
                                      isAvailable ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: isAvailable ? () {} : null,
                                child: const Text(
                                  'Request Send',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
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
    );
  }
}
