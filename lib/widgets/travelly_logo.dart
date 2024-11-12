import 'package:flutter/material.dart';

class TravellyLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text("T", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple)),
        Text("r", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
        Text("a", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple)),
        Text("v", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
        Text("e", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple)),
        Text("l", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
        Text("l", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple)),
        Text("y", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }
}
