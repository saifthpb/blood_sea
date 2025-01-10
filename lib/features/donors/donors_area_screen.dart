import 'package:blood_sea/features/clients/client_area_screen.dart';
import 'package:flutter/material.dart';

class DonorsAreaScreen extends StatefulWidget {
  const DonorsAreaScreen({super.key});

  @override
  State<DonorsAreaScreen> createState() => _DonorsAreaScreenState();
}

class _DonorsAreaScreenState extends State<DonorsAreaScreen>{
  
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Notification from Client's",
              style: TextStyle(
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.green
              ),
            ),
            const Divider(height: 5,),
            const SizedBox(height: 10,),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "A person name sent you a request. Are you available? If you are agree please contact to ..01711775577",
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
        IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const ClientAreaScreen(),));

        },
            icon: const Icon(Icons.arrow_right,
            color: Colors.green,
                size: 50,))

          ],
        ),
      );
  }
}