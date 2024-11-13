import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore access.
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication.
import 'edit_profile_screen.dart'; // Importing the screen to edit the profile.
import 'theme_provider.dart'; // Importing the theme provider for managing theme changes.
import 'package:provider/provider.dart'; // Importing provider for state management.

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = ""; // Variable to store the username.
  String bio = ""; // Variable to store the bio
  // We will add profile picture last
  String email = "";

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Fetch username when widget initializes.
  }

  Future<void> _fetchUserInfo() async {
    try {
      // Get the current user ID
      String userId = FirebaseAuth.instance.currentUser!.uid;
      
      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      // Check if document exists and extract username
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username']; // Assuming 'username' field is present in Firestore.
          bio = userDoc['bio'];
          email = userDoc['email'];
        });
      }
    } catch (e) {
      print("Error fetching: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme provider to manage the dark/light mode toggle.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Sets background color of the app bar to white.
        elevation: 0, // Removes app bar shadow.
        centerTitle: true, // Centers the title in the app bar.
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black, // Sets title text color to black.
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adds padding around the content.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns items to the start of the column.
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30, // Sets avatar size.
                  backgroundImage: AssetImage(''), // Placeholder for profile image.
                ),
                const SizedBox(width: 16), // Adds space between avatar and text.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the start.
                  children: [
                    Text(
                      username, // Displaying the username from Firestore.
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     Text(
                      email, // Email displayed in profile from firebase .
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16), // Adds space after profile section.
            ElevatedButton(
              onPressed: () async {
                // Navigates to EditProfileScreen when button is pressed.
               final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(
                    username:username,
                    email: email,
                    bio: bio
                  )
                  
                  ),
                );
                if (result != null) {
                    setState(() {
                  username = result['username'];
                  bio = result['bio'];
                    }
                    );
                }
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Sets button color to purple.
                minimumSize: const Size(double.infinity, 50), // Button spans full width.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Adds rounded corners to button.
                ),
              ),
              child: const Text(
                'Edit Profile', // Button text.
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24), // Adds space before additional info section.
            const Text(
              'Additional Info', // Header for additional information section.
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Space below header.
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Location: ', // Label for location information.
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Oshawa, ON', // User's location.
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4), // Space before bio section.
            RichText(
              text:  TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Bio: $bio ' , // Label for bio information.
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    //text: 'bio: $bio', // User's bio.
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // Space before preferences section.
            const Text(
              'Preferences', // Header for preferences section.
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Space below header.
            SwitchListTile(
              title: const Text(
                'Receive notifications', // Option to enable/disable notifications.
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: false, // Initial value for notifications switch.
              onChanged: (bool value) {/*value = !value;*/}, // Placeholder function for handling switch state. Please implement @sahil or @rija
            ),
            SwitchListTile(
              title: const Text(
                'Dark mode', // Option to enable/disable dark mode.
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: themeProvider.isDarkMode, // Bind switch value to theme provider's state.
              onChanged: (bool value) {
                // Toggles dark mode when switch is changed.
                themeProvider.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
