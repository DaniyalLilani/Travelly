import 'package:flutter/material.dart';

class TravellyLogo extends StatelessWidget {
  final bool isLoginOrSignup; // Flag to check if we're on the Login or Signup page

  TravellyLogo({this.isLoginOrSignup = false});

  @override
  Widget build(BuildContext context) {
    // Check if we need to adjust the logo colors based on the theme
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // If it's not the login or signup page, just display the logo normally without theme adjustments
    if (!isLoginOrSignup) {
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

    // If it is the login or signup page, change logo colors based on dark mode
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("T", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.purple : Colors.purple)),
        Text("r", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        Text("a", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.purple : Colors.purple)),
        Text("v", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        Text("e", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.purple : Colors.purple)),
        Text("l", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        Text("l", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.purple : Colors.purple)),
        Text("y", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
      ],
    );
  }
}
