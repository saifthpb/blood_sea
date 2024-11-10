import 'package:blood_sea/donorRegistration.dart';
import 'package:blood_sea/fragments/homeFragment.dart';
import 'package:blood_sea/clientSignUp.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class loginActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50], // Light reddish background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Company logo placeholder
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Image.asset('assets/logotx.png'),
              ),
              SizedBox(height: 20),
              // Blood donation symbol
              // Icon(
              //   Icons.bloodtype, // Blood donation symbol
              //   color: Colors.red[800],
              //   size: 80,
              // ),
              SizedBox(height: 20),
              Text(
                "Blood Donation App",
                style: TextStyle(
                  color: Colors.red[800],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Email text field
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.red[800]),
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Password text field
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.red[800]),
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10,),
              // Container(
              //   height: 40,
              //   width: double.infinity,
              //   padding: EdgeInsets.symmetric(horizontal: 5.0,),
              //   child: Text("If You Are Not Registered Member, Please Sign Up",
              //   style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //   color: Colors.blue,
              //     fontStyle: FontStyle.italic,
              //     fontSize: 12,
              //   ),
              //     textAlign: TextAlign.right,
              //   ),
              // ),
              Container(
                height: 40,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.blue, // Default color for the main text
                      fontSize: 12,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "If you are not a registered member, "),
                      TextSpan(
                        text: "please sign up",
                        style: TextStyle(color: Colors.red), // Color for "sign up"
                        recognizer: TapGestureRecognizer()
                          ..onTap = (){
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context)=>clientSignUp()),
                          );
                          }
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right, // Align the text to the right
                ),
              ),

              //SizedBox(height: 10),
              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Login logic goes here
                    Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => homeFragment()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30,),

              // Card(
              //   elevation: 5,
              //   color: Colors.blue,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Padding(
              //       padding: EdgeInsets.all(5.0),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text("Want to be a Donor?",
              //         style: TextStyle(
              //           fontSize: 10,
              //           color: Colors.yellow,
              //           fontStyle: FontStyle.italic,
              //         ),
              //         ),
              //         SizedBox(height: 5,),
              //         Icon(Icons.people_outline,
              //         color: Colors.white,),
              //         Text("Go Donor Registration",
              //         style: TextStyle(
              //             color: Colors.white,
              //           fontWeight: FontWeight.bold,
              //         ),
              //           ),
              //         // Icon(
              //         //   Icons.arrow_right,
              //         //  color: Colors.white,
              //         //     ),
              //       ],
              //     ),
              //
              //   ),
              //
              // )
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => donorRegistration(),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Want to be a Donor?",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.yellow,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 5),
                        Icon(
                          Icons.people_outline,
                          color: Colors.white,
                        ),
                        Text(
                          "Go Donor Registration",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )

            ],
          ),
          
        ),
      ),
      
    );
  }
}
