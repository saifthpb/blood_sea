import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blood_sea/loginActivity.dart';
import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/fragments/profileFragment.dart';
import 'package:blood_sea/fragments/searchFragment.dart';
import 'package:blood_sea/fragments/searchResultFragment.dart';
import 'package:blood_sea/fragments/notificationFragment.dart';
import 'package:blood_sea/fragments/shareFragment.dart';
import 'package:blood_sea/fragments/privacyPolicyFragment.dart';
import 'package:blood_sea/fragments/contactFragment.dart';

class searchFragment extends StatefulWidget {
  _searchFragment createState() => _searchFragment();
}

class _searchFragment extends State<searchFragment> {
  //const searchFragment({super.key});

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
          title: Text("Search", style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24
          ),),
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
              Divider(height: 2,),

              ListTile(
                leading: Icon(Icons.arrow_back),
                title: Text("Privacy Policy"),
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


        body: Text("Search Your Donor"),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.red,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
            items:[
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
    child: Text(
    "+",
    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    ),
      ),

      );
  }
}
