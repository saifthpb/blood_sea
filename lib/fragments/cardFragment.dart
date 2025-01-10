import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class cardFragment extends StatelessWidget {
  const cardFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            height: 100,
            width: 100,
            child: const Card(
              color: Colors.red,
              elevation: 6,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: 100,
            width: 100,
            child: const Card(
              color: Colors.red,
              elevation: 6,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: 100,
            width: 100,
            child: const Card(
              color: Colors.red,
              elevation: 6,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: 100,
            width: 100,
            child: const Card(
              color: Colors.red,
              elevation: 6,
            ),
          )
        ],
      ),


    );
  }
}
