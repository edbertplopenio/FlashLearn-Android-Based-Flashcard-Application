import 'package:flutter/material.dart';
import './screens/welcome_screen.dart';
import './screens/home_screen.dart';
import './theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FlashLearn',
          theme: lightMode,
          home: snapshot.data,
        );
      },
    );
  }
}
