import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile/theme_provider.dart';
import 'screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import '../../widgets/travelly_logo.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'maps/map_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'com.travelly.app', // this gets around duplicate firebase name issue
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initializeNotifications();
  await dotenv.load(fileName: '.mapkey.env');

  final themeProvider = ThemeProvider();
  final isDarkMode = await _loadDarkModePreference();
  themeProvider.setDarkMode(isDarkMode); // Initialize the ThemeProvider with the value

  runApp(
    ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider, // Pass the initialized ThemeProvider instance
      child: MyApp(),
    ),
  );
}

Future<bool> _loadDarkModePreference() async {
  final db = await DatabaseHelper().database;
  final result = await db.query(
    'settings',
    columns: ['isDarkMode'],
    limit: 1,
  );

  if (result.isNotEmpty) {
    return result.first['isDarkMode'] == 1; // Check if the value is true (1 in SQLite)
  }
  return false; // Default to light mode if no preference is stored
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'Default Channel',
      description: 'This is the default notification channel.',
      importance: Importance.high,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

final DatabaseHelper _dbHelper = DatabaseHelper();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Travelly',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.currentTheme,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup_screen': (context) => SignupScreen(),
        '/main': (context) => MyHomePage()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  late String _userId = "guest_user"; // Default value
  late String _userName = "Guest";    // Default value
  List<Widget>? _pages;               // Make _pages nullable

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid; // Use the UID as the document ID
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            _userId = userId;
            _userName = data?['username'] ?? "Unknown User";
            _initializePages();
          });
        } else {
          setState(() {
            _userId = userId;
            _userName = "Unknown User";
            _initializePages();
          });
        }
      } else {
        setState(() {
          _userId = "guest_user";
          _userName = "Guest";
          _initializePages();
        });
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      setState(() {
        _userId = "error_user";
        _userName = "Error User";
        _initializePages();
      });
    }
  }

  void _initializePages() {
    _pages = [
      HomeScreen(userId: _userId),
      BudgetScreen(),
      CalendarScreen(initialDate: DateTime.now(), userId: _userId, username: _userName),
      MapView(thunderforestApiKey: dotenv.env['THUNDERFOREST_API_KEY']!),
      ProfileScreen(),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: TravellyLogo(isLoginOrSignup: false),
      ),
      body: _pages![_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
