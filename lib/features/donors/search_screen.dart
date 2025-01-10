import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:blood_sea/features/home/home.dart';
import 'package:blood_sea/features/profile/profile.dart';
import 'package:blood_sea/features/donors/search.dart';
import 'package:blood_sea/features/donors/search_result_screen.dart';
import 'package:blood_sea/features/notifications/notifications.dart';
import 'package:blood_sea/features/share/share.dart';
import 'package:blood_sea/features/privacy_policy/privacy_policy.dart';
import 'package:blood_sea/features/contact/contact_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  //const SearchScreen({super.key});

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: const Text("Search", style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24
          ),),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.redAccent),
                accountName: Text("Saiful Sarwar"),
                accountEmail: Text("ssb2001@gmail.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/ssbf.png'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context)=> homeFragment()),);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile fragment
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => profileFragment()),);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("Search"),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to search fragment
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),);
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_emergency),
                title: const Text("Contact"),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to contact page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const contactFragment()),);
                },
              ),
              const Divider(height: 2,),

              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text("Privacy Policy"),
                onTap: () {
                  //Navigator.pop(context);
                  Navigator.pop(context);
                  // Navigate to contact page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => privacyPolicyFragment()),);
                },
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {
                  // Implement logout functionality
                  _logout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text("Back"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),


        body: const Text("Search Your Donor"),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.red,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
            items:const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
            ],
        ),

    floatingActionButton: FloatingActionButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => searchResultFragment()),
    );


    },
    backgroundColor: Colors.red,
    tooltip: "Register as Donor",
    child: const Text(
    "+",
    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    ),
      ),

      );
  }
}
