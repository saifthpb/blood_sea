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

class searchFragment extends StatelessWidget {
  const searchFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
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
