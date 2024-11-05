import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class homeFragment extends StatelessWidget {
  const homeFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          // height: 600,
          // width: 600,
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Need Blood??",
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )
                  ),
                  child: Text(
                    "Send Request",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20,),
                Text(
                  "Total Donor:....?????",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold
                  ),
                ),
                //donor list text
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.all(5),
                  color: Colors.green,
                  child: Text(
                    "See Donor List",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(height: 20,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Card(
                          elevation: 6,
                          color: Colors.red,
                          child: Padding(padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Text("Want to be a Donor?", style: TextStyle(color: Colors.white),),

                                Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.yellow,),
                                // SizedBox(height: 20,),
                                Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),

                        )
                    ),
                    Expanded(
                        child: Card(
                          elevation: 6,
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Total Client", style: TextStyle(fontSize: 14,
                                  color: Colors.white,
                                ),
                                ),
                                Icon(Icons.info,
                                  size: 50,
                                  color: Colors.yellow,
                                ),
                                Text("12154",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        )
                    ),

                  ],
                ),
                SizedBox(height: 30,),
                Text(
                  "This Application Developed by Saiful Sarwar",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),

                Text("All Right Reserved: TeamExpressBD",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),

              ],
            )


        ),

      ),

    );


  }
}
