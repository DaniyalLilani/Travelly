import 'dart:io';  
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
  // Initialize the plugin for Android and iOS
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create a notification channel for Android 8.0+
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel', // ID of the channel
      'Default Channel', // Name of the channel
      description: 'This is the default notification channel.',
      importance: Importance.high, // High priority for the notification
      playSound: true,
    );

    // Create the channel (required for Android 8.0 and above)
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
      themeMode: themeProvider.currentTheme, // Use the theme from ThemeProvider
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),

      initialRoute: '/login',  // Force the app to always start at the login page
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

  late String _userId; // Fetch and store the user ID from your auth system.

  @override
  void initState() {
    super.initState();
    // Replace with your logic to fetch the user ID, such as from FirebaseAuth
    _fetchUserId();;
  }

  Future<void> _fetchUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        _userId = user?.email ?? user?.uid ?? "guest_user"; // Use email or UID, fallback to guest_user.
      });
    } catch (e) {
      debugPrint("Error fetching user ID: $e");
      setState(() {
        _userId = "error_user";
      });
    }
  }

  late final List<Widget> _pages = [
    HomeScreen(userId: _userId),        
    BudgetScreen(),
    CalendarScreen(initialDate: DateTime.now(),userId: _userId,),
    MapView(thunderforestApiKey: dotenv.env['THUNDERFOREST_API_KEY']!),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
        title: TravellyLogo(isLoginOrSignup: false,), 
      ),
      body: _pages[_currentIndex],
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