import 'package:firebase_core/firebase_core.dart';
import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/fragments/notificationFragment.dart';
import 'package:blood_sea/fragments/profileFragment.dart';
import 'package:blood_sea/fragments/searchFragment.dart';
import 'package:blood_sea/splashScreenActivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: splashScreenActivity(),
    );
  }
}

class MainActivity extends StatefulWidget {
  //const SplashScreenActivity({super.key});
  @override
  _MainActivityState createState() => _MainActivityState();
}
class _MainActivityState extends State<MainActivity> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    homeFragment(),
    searchFragment(),
    profileFragment(),
    notificationFragment(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text("Blood Donation App"),
            foregroundColor: Colors.yellow,
            elevation: 10,
            titleSpacing: 10,
              bottom:TabBar(
             isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,

            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.search)),
              Tab(icon: Icon(Icons.person)),
            ]
             ),
          ),
          body: _pages[_selectedIndex],
          // TabBarView(
          //     children: [
          //       homeFragment(),
          //       searchFragment(),
          //       profileFragment(),
          //
          // ],
          // ),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  padding: EdgeInsets.all(0),
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.red),
                    accountName: Text("Saiful Sarwar"),
                    accountEmail: Text("ssb2001@gmail.com"),
                    currentAccountPicture: CircleAvatar(
                      radius: 30.0,
                        backgroundImage: AssetImage('assets/ssbf.png'),


                    ),
                    margin: const EdgeInsets.all(0),
                    

                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Home"),
                  onTap: (){
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex=0;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Profile"),
                  onTap: (){
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex=2;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.search),
                  title: Text("Search"),
                  onTap: (){
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex=1;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.contact_emergency),
                  title: Text("Contact"),
                  onTap: (){
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                  onTap: (){

                  },
                ),
                ListTile(
                  leading: Icon(Icons.arrow_back),
                  title: Text("Back"),
                  onTap: (){
                    Navigator.pop(context); //for drawer close
                  },
                ),
              ],
            ),
          ),

          bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.red,
              selectedItemColor: Colors.white, // Color for selected item
              unselectedItemColor: Colors.white, // Color for unselected items
              currentIndex: _selectedIndex,
            onTap: _onItemTapped,

            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),

            ]

        )


          ,

        ),
    );
  }
}



