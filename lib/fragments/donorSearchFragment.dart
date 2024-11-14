import 'package:blood_sea/fragments/notificationFragment.dart';
import 'package:blood_sea/fragments/shareFragment.dart';
import 'package:blood_sea/loginActivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For session management
import 'package:blood_sea/fragments/donorSearchFragment.dart';
import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/fragments/profileFragment.dart';
import 'package:blood_sea/fragments/searchFragment.dart';
import 'package:blood_sea/fragments/contactFragment.dart';

class donorSearchFragment extends StatefulWidget {
  @override
  _DonorSearchFragmentState createState() => _DonorSearchFragmentState();
}

class _DonorSearchFragmentState extends State<donorSearchFragment> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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

  final List<Map<String, String>> donorList = [
    {'name': 'Sheikh Saiful', 'mobile': '017156458', 'address': 'Dhanmondi, Dhaka'},
    {'name': 'Rahim Uddin', 'mobile': '016789123', 'address': 'Mirpur-10, Dhaka'},
    {'name': 'Kamal Hossain', 'mobile': '018452367', 'address': 'Banani, Dhaka'},
    {'name': 'Rashid Khan', 'mobile': '015762341', 'address': 'Gulshan, Dhaka'},
  ];

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
        title: Text("Donor Search"),
        foregroundColor: Colors.white,
        elevation: 5,
        titleSpacing: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Donors Area"),
            Padding(
              padding: EdgeInsets.all(5),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
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
                  print("Selected Blood Group: $value");
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
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
              padding: EdgeInsets.all(5),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Patient's Location",
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      suffixIcon: Icon(Icons.location_on),
                    ),
                  );
                },
                onSelected: (String selection) {
                  print("Selected Hospital: $selection");
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: () {
                  print("Show Donor List button clicked");
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  shadowColor: Colors.black54,
                  backgroundColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.orangeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: Text(
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
            SizedBox(height: 20),
            // Donor List Table
            // Expanded(
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     child: DataTable(
            //       columnSpacing: 20,
            //       border: TableBorder.all(color: Colors.grey),
            //       columns: [
            //         DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
            //         DataColumn(label: Text('Mobile No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
            //         DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
            //         DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
            //       ],
            //       rows: donorList.map((donor) {
            //         return DataRow(cells: [
            //           DataCell(Text(donor['name']!)),
            //           DataCell(Text(donor['mobile']!)),
            //           DataCell(Text(donor['address']!)),
            //           DataCell(
            //             ElevatedButton(
            //               onPressed: () {
            //                 print("Send request to ${donor['name']}");
            //               },
            //               style: ElevatedButton.styleFrom(
            //                 backgroundColor: Colors.redAccent,
            //                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            //               ),
            //               child: Text("Send Request",
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 8,
            //               ),),
            //             ),
            //           ),
            //         ]);
            //       }).toList(),
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 10, // Reduce space between columns
                  headingRowHeight: 35, // Smaller header row height
                  dataRowHeight: 40, // Smaller data row height
                  columns: const [
                    DataColumn(
                      label: Text(
                        "Name",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Mobile No",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Address",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Action",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text("Sheikh", style: TextStyle(fontSize: 12))),
                      DataCell(Text("017156458", style: TextStyle(fontSize: 12))),
                      DataCell(Text("Dhanmondi", style: TextStyle(fontSize: 12))),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            // Add your button action here
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            backgroundColor: Colors.redAccent,
                            minimumSize: Size(70, 30),
                          ),
                          child: Text(
                            "Send Request",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Rahim", style: TextStyle(fontSize: 12))),
                      DataCell(Text("016123456", style: TextStyle(fontSize: 12))),
                      DataCell(Text("Mirpur", style: TextStyle(fontSize: 12))),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            backgroundColor: Colors.redAccent,
                            minimumSize: Size(70, 30),
                          ),
                          child: Text(
                            "Send Request",
                            style: TextStyle(fontSize: 12, color: Colors.white),

                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

          ],
        ),
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

    );
  }
}
