import 'dart:async';
import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:blood_sea/features/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      // Wait for 2 seconds to show splash screen
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;

      // Check if user is signed in
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (!mounted) return;

      if (currentUser != null) {
        // User is signed in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // No user is signed in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      // Handle any errors
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
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
