import 'package:blood_sea/features/clients/client_area_screen.dart';
import 'package:blood_sea/features/notifications/notifications.dart';
import 'package:blood_sea/features/share/share.dart';
import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For session management
import 'package:blood_sea/features/donors/donor_search_screen.dart';
import 'package:blood_sea/features/home/home.dart';
import 'package:blood_sea/features/profile/profile.dart';
import 'package:blood_sea/features/donors/search.dart';
import 'package:blood_sea/features/contact/contact_screen.dart';

class ClientAreaScreen extends StatefulWidget {
  const ClientAreaScreen({super.key});

  @override
  _ClientAreaScreenState createState() => _ClientAreaScreenState();
}
  class _ClientAreaScreenState extends State<ClientAreaScreen>{
  //const ClientAreaScreen({super.key});

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
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
        title: const Text("Home"),
        foregroundColor: Colors.white,
        elevation: 5,
        titleSpacing: 0,
        actions: [

          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Handle settings tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>const shareFragment()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>notificationFragment()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>searchFragment()));
            },
          ),
        ],
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
                  MaterialPageRoute(builder: (context) => searchFragment()),);
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Notification from donor",
            style: TextStyle(
              fontSize: 25,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.red
            ),),
            Divider(height: 5,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text("A person name Sazal accepted your request. Please contact with the number: 8801759653250",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.red,
      selectedItemColor: Colors.white, // Color for selected item
      unselectedItemColor: Colors.white, // Color for unselected items
      currentIndex: _selectedIndex,
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });

        // Navigate to the respective pages based on the index
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => homeFragment()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => searchFragment()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => profileFragment()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => notificationFragment()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Notifications",
        ),
      ],
    ),
    );
  }
}