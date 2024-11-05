import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/fragments/notificationFragment.dart';
import 'package:blood_sea/fragments/profileFragment.dart';
import 'package:blood_sea/fragments/searchFragment.dart';
import 'package:blood_sea/splashScreenActivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
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

class MainActivity extends StatelessWidget {
  //const SplashScreenActivity({super.key});

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
            //
            //
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.search)),
              Tab(icon: Icon(Icons.person)),
            //
            ]
             ),
          ),
          body: TabBarView(
              children: [
                homeFragment(),
                searchFragment(),
                profileFragment(),

          ],
          ),
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
                  onTap: (){},
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Profile"),
                  onTap: (){},
                ),
                ListTile(
                  leading: Icon(Icons.search),
                  title: Text("Search"),
                  onTap: (){},
                ),
                ListTile(
                  leading: Icon(Icons.contact_emergency),
                  title: Text("Contact"),
                  onTap: (){},
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

            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),

            ]

        )


          ,

        ),
    );
  }
}



