import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// NOTE: TODO Profile picture later, it may take some time as were not using remote links but actually uploading images from the device
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();

  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser() async {
    try {
      // Register user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      User? user = userCredential.user;

      // Create user profile in Firestore
      await _firestore.collection('users').doc(user?.uid).set({
        'email': emailController.text.trim(),
        'userID': user?.uid,
        'username': usernameController.text.trim(),
        'password': passwordController.text.trim(),
        'bio': ""
        

        // Add other user fields if necessary
      });

      // Navigate to home or main screen after registration
      Navigator.of(context).pushReplacementNamed('/main');
    } catch (e) {
      print("Error: $e");
      // Handle errors (e.g., show a dialog to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up for Travelly')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'username'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerUser,
              child: Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Go back to login
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
