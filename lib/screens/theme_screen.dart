import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/theme.dart';
import '../theme/gradient_color_option.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
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
    Color(0xFFFFD1DC),
    Color(0xFFFFE4E1),
    Color(0xFFFFDAB9),
    Color(0xFFFFFACD),
    Color(0xFFFAFAD2),
    Color(0xFFE0FFFF),
    Color(0xFFE6E6FA),
    Color(0xFFD8BFD8),
    Color(0xFFF0E68C),
    Color(0xFF98FB98),
    Color(0xFF3E4A89),
    Color(0xFF4B9CD3),
    Color(0xFF6B9080),
    Color(0xFF34568B),
    Color(0xFF92A8D1),
    Color(0xFF009688),
    Color(0xFF00BFA5),
    Color(0xFF00695C),
    Color(0xFF4A6572),
    Color(0xFF2C3E50),
  ];

  // Updated gradient options
  final List<GradientColorOption> gradientOptions = [
    GradientColorOption(LinearGradient(colors: [Color(0xFFf46b45), Color(0xFFeea849)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFF4568dc), Color(0xFFb06ab3)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFF6a11cb), Color(0xFF2575fc)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFFff9a9e), Color(0xFFfad0c4)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFFff758c), Color(0xFFff7eb3)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFFff9966), Color(0xFFff5e62)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFF42e695), Color(0xFF3bb2b8)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFF30cfd0), Color(0xFF330867)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFFffe259), Color(0xFFffa751)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    GradientColorOption(LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
  ];

  Color selectedColor = lightColorScheme.primary;
  GradientColorOption? selectedGradient;

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
  }

  Future<void> _loadSelectedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final int? colorValue = prefs.getInt('theme_color');
      if (colorValue != null) {
        selectedColor = Color(colorValue);
      }

      final String? gradientJson = prefs.getString('theme_gradient');
      if (gradientJson != null) {
        selectedGradient = GradientColorOption.fromJson(json.decode(gradientJson));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Settings', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: selectedGradient != null ? selectedGradient!.gradient.colors.first : selectedColor,
        flexibleSpace: selectedGradient != null
            ? Container(
                decoration: BoxDecoration(
                  gradient: selectedGradient!.gradient,
                ),
              )
            : null,
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
                itemCount: themeColors.length + gradientOptions.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = lightColorScheme.primary;
                          selectedGradient = null;
                        });
                        _applyTheme(selectedColor, null);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == lightColorScheme.primary && selectedGradient == null ? Colors.black : Colors.transparent,
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
                  } else if (index <= themeColors.length) {
                    final color = themeColors[index - 1];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                          selectedGradient = null;
                        });
                        _applyTheme(color, null);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color == selectedColor && selectedGradient == null ? Colors.black : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: color == selectedColor && selectedGradient == null
                            ? Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  } else {
                    final gradient = gradientOptions[index - themeColors.length - 1];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = gradient.gradient.colors.first;
                          selectedGradient = gradient;
                        });
                        _applyTheme(gradient.gradient.colors.first, gradient);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: gradient.gradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gradient == selectedGradient ? Colors.black : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: gradient == selectedGradient
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

  void _applyTheme(Color color, GradientColorOption? gradient) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', color.value);

    if (gradient != null) {
      await prefs.setString('theme_gradient', json.encode(gradient.toJson()));
    } else {
      await prefs.remove('theme_gradient');
    }

    // Update the theme in your app (you might need to use a state management solution here)
    // For example, using Provider:
    // Provider.of<ThemeProvider>(context, listen: false).updateTheme(color);
  }
}
