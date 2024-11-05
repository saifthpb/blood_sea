import 'dart:async';
import 'package:flutter/material.dart';
import 'loginActivity.dart'; // Import the Login page

class splashScreenActivity extends StatefulWidget {
  @override
  _splashScreenActivityState createState() => _splashScreenActivityState();
}

class _splashScreenActivityState extends State<splashScreenActivity> {
  @override
  void initState() {
    super.initState();
    // Timer to navigate to the Login page after 3 seconds
    Timer(Duration(seconds: 3), () {
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
      body: Center(
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
              "Blood Donation App",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
