import 'package:blood_sea/fragments/notificationFragment.dart';
import 'package:blood_sea/fragments/privacyPolicyFragment.dart';
import 'package:blood_sea/fragments/shareFragment.dart';
import 'package:blood_sea/loginActivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For session management
import 'package:blood_sea/fragments/donorSearchFragment.dart';
//import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/fragments/profileFragment.dart';
import 'package:blood_sea/fragments/searchFragment.dart';
import 'package:blood_sea/fragments/contactFragment.dart';
import 'package:blood_sea/fragments/donorListFragment.dart';
import 'donorRegistration.dart';

class homeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<homeFragment> {
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
        title: Text("Home"),
        foregroundColor: Colors.white,
        elevation: 5,
        titleSpacing: 0,
        actions: [

          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Handle settings tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>shareFragment()));
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>notificationFragment()));
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 80,
              color: Colors.redAccent,
            ),
            SizedBox(height: 20),
            // Text(
            //   "Welcome to Blood Donation App!",
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.redAccent,
            //   ),
            // ),
            SizedBox(height: 10),
            // Text(
            //   "Save lives by donating blood.",
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.black54,
            //   ),
            // ),
            SizedBox(height: 20,),
            Text("Need Blood?",
              style: TextStyle(
              fontSize: 24,
              color: Colors.red,
                fontWeight: FontWeight.bold,
            ),
      ),
            GestureDetector(
              onTap: (){
                // Navigate to privacyPolicyFragment.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => privacyPolicyFragment()),
                );
              },
              child: Text("read terms and conditions",
              style:
                TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context)=> donorSearchFragment(),
                ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(double.infinity, 50),
              ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Send Request",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5, width: 8,),
                      Icon(
                        Icons.arrow_right_alt,
                        size: 30,
                      ),
                    ],
                )


            ),
            SizedBox(height: 10,),
            Text("Total Donor: .....Dynamic Code",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              //fontFamily: 'fonts/Lato-Bold.ttf',
              color: Colors.green,
            ),
            ),
            SizedBox(height: 10,),
            OutlinedButton(
              onPressed: (){
                //Navigator.push(context, MaterialPageRoute(builder: (context) => donorList()),);
                Navigator.push(context, MaterialPageRoute(builder: (context) => donorListFragment()),);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
                foregroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal:8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(10),
                  ),
                ),
              minimumSize: Size(50, 36)
              ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                    ),
                    SizedBox(width: 5,),
                    Text("See Donor List"),

                  ],
                ),
            ),
            SizedBox(width: 5,),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center row contents if needed
                children: [
                  Text(
                    "Want to be a Donor?",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 8), // Space between text and image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => donorRegistration()),);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child:  Container(
                            height: 50,
                            width: 80,
                            color: Colors.red,
                            child: Center(
                              child:   Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            SizedBox(height: 15,),
            //start donor registration text

            //start donor registration text
            Card(
              elevation: 20,
                color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.white,
                        size: 40,
                    ),
                    SizedBox(height: 5,),
                    Text("Total Clients: 2145",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
        items: [
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
