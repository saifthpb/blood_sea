import 'dart:async';
import 'package:flutter/material.dart';
import 'loginActivity.dart'; // Import the Login page

class splashScreenActivity extends StatefulWidget {
  const splashScreenActivity({super.key});

  @override
  _splashScreenActivityState createState() => _splashScreenActivityState();
}

class _splashScreenActivityState extends State<splashScreenActivity> {
  @override
  void initState() {
    super.initState();
    // Timer to navigate to the Login page after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginActivity()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[800], // Reddish background color
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Blood donation symbol
            Icon(
              Icons.bloodtype,
              color: Colors.white,
              size: 100,
            ),
            SizedBox(height: 20),
            // App name or slogan
            Text(
              "Welcome to Blood Donation App",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: Colors.white, // Color of the line
              thickness: 1, // Thickness of the line
              height: 10, // Space around the line
            ),
            Text(
              "Save Lives by Donating Blood",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 150,),
            Text(
              "Developped By Saiful Sarwar || Roquib Pramanik",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: Colors.white, // Color of the line
              thickness: 1, // Thickness of the line
              height: 20, // Space around the line
            ),
            Text(
              "Supported by teamExpressBD",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
