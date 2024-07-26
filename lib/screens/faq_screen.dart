import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  Color themeColor = lightColorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadThemeColor();
  }

  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final int colorValue = prefs.getInt('theme_color') ?? lightColorScheme.primary.value;
      themeColor = Color(colorValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back arrow
        title: const Text(
          'FAQ',
          style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Raleway'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              '1. How do I create an account?\n\n- Go to the signup and click "Create an account".\n\n2. How do I create a new flashcard set?\n\n- Navigate to the flashcard set management section and click "Create a new flashcard set".\n\n3. How do I add a new flashcard to a set?\n\n- Open the flashcard set and click "Add a new flashcard".\n\n4. How can I contact support?\n\n- Reach out to us via email at support@flashlearn.com or call us at +639856034982.',
              style: TextStyle(fontSize: 15, fontFamily: 'Raleway', fontWeight: FontWeight.w600),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 40),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
