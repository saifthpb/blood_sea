import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const donorRegistration());
}
class donorRegistration extends StatelessWidget {
  const donorRegistration({super.key});

  MySnackBar(String message, BuildContext context){
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),

    );
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 60),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 20),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        )

    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green),
      darkTheme: ThemeData(primaryColor: Colors.cyan),



      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          title: const Text("Blood Donation App", style: TextStyle(color: Colors.yellow),),
          backgroundColor: Colors.red,
          titleSpacing: 10,
          elevation: 1,
          actions: [
            IconButton(onPressed: (){
              MySnackBar("I am Home", context);
            },
                icon: const Icon(Icons.home, color: Colors.white,)),
            IconButton(onPressed: (){MySnackBar("I am Home", context);}, icon: const Icon(Icons.facebook, color: Colors.white,)),
            IconButton(onPressed: (){MySnackBar("I am Home", context);}, icon: const Icon(Icons.search), color: Colors.white,),
            IconButton(onPressed: (){MySnackBar("I am Home", context);}, icon: const Icon(Icons.settings, color: Colors.white,)),
          ],
        ),
        //body: (),
        //drawer: (),
        //endDrawer: (),
        bottomNavigationBar: BottomNavigationBar  (
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification")

          ],
          backgroundColor: Colors.red,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,

        ),
        floatingActionButton: FloatingActionButton(
            elevation: 10,
            child: Icon(Icons.add),
            backgroundColor: Colors.red,
            onPressed: (){
              MySnackBar("Hello Foat", context);
            }

        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                padding: EdgeInsets.all(0),
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color:Colors.red),
                  accountName: Padding(padding: EdgeInsets.only(top:36.0),
                    child: Text("Saiful Sarwar"),
                  ),
                  accountEmail: Padding(padding: EdgeInsets.only(top: 8.0),
                    child: Text("ssb2001@gmail.com"),
                  ),
                  // currentAccountPicture: Image.network(".https://w7.pngwing.com/pngs/67/315/png-transparent-flutter-hd-logo-thumbnail.png"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('assets/ssbf.png'),


                  ),

                ),

              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text("Search"),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Profile"),
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text("Share"),
              ),
              ListTile(
                leading: Icon(Icons.policy),
                title: Text("Policy"),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
              ),
            ],
          ),
        ),
        // endDrawer: Drawer(
        //   child: ListView(
        //     children: [
        //       DrawerHeader(
        //         padding: EdgeInsets.all(0),
        //         child: UserAccountsDrawerHeader(
        //           decoration: BoxDecoration(color:Colors.red),
        //           accountName: Padding(padding: EdgeInsets.only(top:36.0),
        //             child: Text("Saiful Sarwar"),
        //           ),
        //           accountEmail: Padding(padding: EdgeInsets.only(top: 8.0),
        //             child: Text("ssb2001@gmail.com"),
        //           ),
        //           // currentAccountPicture: Image.network(".https://w7.pngwing.com/pngs/67/315/png-transparent-flutter-hd-logo-thumbnail.png"),
        //           currentAccountPicture: CircleAvatar(
        //             backgroundImage: AssetImage('assets/ssbf.png'),
        //
        //
        //           ),
        //
        //         ),
        //
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.home),
        //         title: Text("Home"),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.search),
        //         title: Text("Search"),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.person),
        //         title: Text("Profile"),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.share),
        //         title: Text("Share"),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.policy),
        //         title: Text("Policy"),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.logout),
        //         title: Text("Logout"),
        //       ),
        //     ],
        //   ),
        // ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10), child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Full Name",

              ),
            )
              ,),
            Padding(
              padding: EdgeInsets.all(10), child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email Account",

              ),
            )
              ,),
            Padding(
              padding: EdgeInsets.all(10), child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Mobile Number",
              ),
            )
              ,),
            Padding(
              padding: EdgeInsets.all(10), child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Select Blood Group",
              ),
            )
              ,),
            Padding(
              padding: EdgeInsets.all(10), child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Select District",
              ),
            )
              ,),
            Padding(
              padding: EdgeInsets.all(10), child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Thana/Upazila/City",
              ),
            )
              ,),
            Padding(padding: EdgeInsets.all(10),
              child: ElevatedButton(onPressed: (){}, child: Text("Submit"), style: buttonStyle,)
              ,)
          ],
        ),

      ),
    );
  }
}
