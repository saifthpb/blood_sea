import 'package:blood_sea/features/donors/donors_area_screen.dart';
import 'package:flutter/material.dart';

class DonorSearchScreen extends StatefulWidget {
  const DonorSearchScreen({super.key});

  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    print("Selected Blood Group: $value");
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
                    print("Selected Hospital: $selection");
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: () {
                    print("Show Donor List button clicked");
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
                        const DataCell(Text("Sheikh", style: TextStyle(fontSize: 12))),
                        const DataCell(Text("017156458", style: TextStyle(fontSize: 12))),
                        const DataCell(Text("Dhanmondi", style: TextStyle(fontSize: 12))),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              // Add your button action here
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              backgroundColor: Colors.redAccent,
                              minimumSize: const Size(70, 30),
                            ),
                            child: const Text(
                              "Send Request",
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text("Rahim", style: TextStyle(fontSize: 12))),
                        const DataCell(Text("016123456", style: TextStyle(fontSize: 12))),
                        const DataCell(Text("Mirpur", style: TextStyle(fontSize: 12))),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> const DonorsAreaScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              backgroundColor: Colors.redAccent,
                              minimumSize: const Size(70, 30),
                            ),
                            child: const Text(
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
      );
  }
}
