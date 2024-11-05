import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class profileFragment extends StatelessWidget {
  // Sample data for demonstration
  final List<Map<String, String>> persons = [
    {
      'name': 'Abdur Roquibe',
      'phone': '01711184339',
      'email': 'ssb2001@gmail.com',
      'bloodGroup': 'O+',
      'location': 'Paikpara, Mirpur 1, Dhaka'
    },
    {
      'name': 'Reneka Ahmed',
      'phone': '01676163181',
      'email': 'reneka@gmail.com',
      'bloodGroup': 'B+',
      'location': 'Maghbazar, Dhaka'
    },
    // Add more person entries here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donor Profiles',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.8, // Adjust to control card height
        ),
        itemCount: persons.length,
        itemBuilder: (context, index) {
          final person = persons[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Person's Name
                  Text(
                    person['name'] ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Phone Number
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          person['phone'] ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Email Address
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          person['email'] ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Blood Group
                  Row(
                    children: [
                      Icon(Icons.bloodtype, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text(
                        person['bloodGroup'] ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Location Address
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          person['location'] ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
