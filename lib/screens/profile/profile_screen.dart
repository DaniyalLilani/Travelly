import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import 'theme_provider.dart';
import '../../services/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = ""; 
  String bio = ""; 
  String email = "";
  String location = "";
  bool notificationsEnabled = false; 
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); 
    _initializeNotifications(); 
    _loadDarkModePreference();

  }

  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request permission for notifications
  Future<void> _requestNotificationPermission() async {
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (result != null && result) {
      setState(() {
        notificationsEnabled = true;
      });
      _showNotification(); // Show notification when permissions are granted
      print("Notification permission granted.");
    } else if (result == null) {
      setState(() {
        notificationsEnabled = true;
      });
      _showNotification(); // Show notification on Android automatically
      print("Notification permission granted automatically.");
    }
  }

  // Show notification after permission is granted
  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'General Notifications',
      channelDescription: 'This channel is for general notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notifications',
      'Notifications are enabled!',
      notificationDetails,
    );
  }

  Future<void> _loadDarkModePreference() async {
  bool isDarkMode = await _dbHelper.getIsDarkMode();
  Provider.of<ThemeProvider>(context, listen: false).setDarkMode(isDarkMode);
}



  Future<void> _fetchUserInfo() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'];
          bio = userDoc['bio'];
          email = userDoc['email'];
          location = userDoc['location'];
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color.fromARGB(255, 227, 175, 236),
                  backgroundImage: AssetImage('lib/assets/Default_pfp.jpg'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(
                      username: username,
                      email: email,
                      bio: bio,
                      location: location,
                  )),
                );
                if (result != null) {
                  setState(() {
                    username = result['username'];
                    bio = result['bio'];
                    location = result['location'];
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Additional Info',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
                children: [
                  TextSpan(
                    text: 'Bio: $bio ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
                children: [
                  TextSpan(
                    text: 'Location: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                  ),
                  TextSpan(
                    text: location,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text(
                'Receive notifications',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  notificationsEnabled = value;
                });
                if (value) {
                  _requestNotificationPermission();
                }
              },
            ),
            SwitchListTile(
              title: const Text(
                'Dark mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: themeProvider.isDarkMode,
              onChanged: (bool value) async {
                themeProvider.toggleTheme(value);
                await _dbHelper.setIsDarkMode(value); // push to local db
              },
            ),
          ],
        ),
      ),
    );
  }
}
