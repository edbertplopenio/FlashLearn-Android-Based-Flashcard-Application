import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/welcome_screen.dart';
import './screens/home_screen.dart';
import './screens/splash_screen.dart'; // Import the SplashScreen
import './theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('session_token');
    if (sessionToken != null) {
      return const HomeScreen(); // Redirect to HomeScreen if session exists
    }
    return const WelcomeScreen(); // Otherwise, go to WelcomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlashLearn',
      theme: lightMode,
      home: const SplashScreen(), // Start with SplashScreen
    );
  }
}
