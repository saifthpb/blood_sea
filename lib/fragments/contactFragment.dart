import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class contactFragment extends StatelessWidget {
  const contactFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, color: Colors.red,),
            SizedBox(height: 10,),
            Text("Welcome to Contact Page",
            style: TextStyle(color: Colors.blue),),
          ],
        ),
      )
   
    );
  }
}