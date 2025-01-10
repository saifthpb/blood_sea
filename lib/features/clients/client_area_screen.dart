import 'package:flutter/material.dart';

class ClientAreaScreen extends StatefulWidget {
  const ClientAreaScreen({super.key});

  @override
  State<ClientAreaScreen> createState() => _ClientAreaScreenState();
}

class _ClientAreaScreenState extends State<ClientAreaScreen> {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Notification from donor",
            style: TextStyle(
                fontSize: 25,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.red),
          ),
          Divider(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "A person name Sazal accepted your request. Please contact with the number: 8801759653250",
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
    );
  }
}
