import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';  
import 'screens/budget/budget_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile/theme_provider.dart';
import 'screens/map_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

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
        '/main': (context) => MyHomePage(),
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

  final List<Widget> _pages = [
    HomeScreen(),        
    BudgetScreen(),
    CalendarScreen(initialDate: DateTime.now(),),
    MapScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.airplanemode_active, color: Colors.purple, size: 24),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(text: 'T', style: TextStyle(color: Colors.black)),
                  TextSpan(text: 'r', style: TextStyle(color: Colors.purple)),
                  TextSpan(text: 'a', style: TextStyle(color: Colors.black)),
                  TextSpan(text: 'v', style: TextStyle(color: Colors.purple)),
                  TextSpan(text: 'e', style: TextStyle(color: Colors.black)),
                  TextSpan(text: 'l', style: TextStyle(color: Colors.purple)),
                  TextSpan(text: 'l', style: TextStyle(color: Colors.black)),
                  TextSpan(text: 'y', style: TextStyle(color: Colors.purple)),
                ],
              ),
            ),
          ],
        ),
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
