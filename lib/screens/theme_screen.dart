import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  // Define a list of colors for the theme palette
  final List<Color> themeColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Color(0xFFFFD1DC), // pastel pink
    Color(0xFFFFE4E1), // pastel light pink
    Color(0xFFFFDAB9), // pastel peach
    Color(0xFFFFFACD), // pastel lemon chiffon
    Color(0xFFFAFAD2), // pastel light goldenrod yellow
    Color(0xFFE0FFFF), // pastel light cyan
    Color(0xFFE6E6FA), // pastel lavender
    Color(0xFFD8BFD8), // pastel thistle
    Color(0xFFF0E68C), // pastel khaki
    Color(0xFF98FB98), // pastel pale green
    Color(0xFF3E4A89), // dark blue
    Color(0xFF4B9CD3), // medium blue
    Color(0xFF6B9080), // desaturated green
    Color(0xFF34568B), // classic blue
    Color(0xFF92A8D1), // air blue
    Color(0xFF009688), // teal
    Color(0xFF00BFA5), // turquoise
    Color(0xFF00695C), // dark teal
    Color(0xFF4A6572), // blue-grey
    Color(0xFF2C3E50), // midnight blue
  ];

  // Currently selected color
  Color selectedColor = lightColorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
  }

  Future<void> _loadSelectedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final int colorValue = prefs.getInt('theme_color') ?? lightColorScheme.primary.value;
      selectedColor = Color(colorValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Settings', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: selectedColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: themeColors.length + 1, // +1 for the default option
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Default option
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = lightColorScheme.primary;
                        });
                        _applyTheme(selectedColor);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == lightColorScheme.primary ? Colors.black : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "D",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    final color = themeColors[index - 1];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                        _applyTheme(color);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color == selectedColor ? Colors.black : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: color == selectedColor
                            ? Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyTheme(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', color.value);

    // Update the theme in your app (you might need to use a state management solution here)
    // For example, using Provider:
    // Provider.of<ThemeProvider>(context, listen: false).updateTheme(color);
  }
}
