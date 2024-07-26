import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert'; // Import dart:convert for json decoding
import 'mission_screen.dart';
import 'team_screen.dart';
import 'contact_screen.dart';
import 'privacy_screen.dart';
import 'faq_screen.dart';
import '../theme/theme.dart';
import '../theme/gradient_color_option.dart'; // Import GradientColorOption

void main() {
  runApp(MaterialApp(
    home: AboutUsScreen(),
  ));
}

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  Color themeColor = lightColorScheme.primary;
  GradientColorOption? themeGradient;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final int colorValue = prefs.getInt('theme_color') ?? lightColorScheme.primary.value;
      themeColor = Color(colorValue);

      final String? gradientJson = prefs.getString('theme_gradient');
      if (gradientJson != null) {
        themeGradient = GradientColorOption.fromJson(json.decode(gradientJson));
      } else {
        themeGradient = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeGradient != null ? themeGradient!.gradient.colors.first : themeColor,
        flexibleSpace: themeGradient != null
            ? Container(
                decoration: BoxDecoration(
                  gradient: themeGradient!.gradient,
                ),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 2,
              child: Tile(index: 0, text: 'Mission Statement', themeColor: themeColor, themeGradient: themeGradient),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: Tile(index: 1, text: 'Team', themeColor: themeColor, themeGradient: themeGradient),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 2, text: 'Contact Information', themeColor: themeColor, themeGradient: themeGradient),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 3, text: 'Privacy Policy', themeColor: themeColor, themeGradient: themeGradient),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 4,
              mainAxisCellCount: 2,
              child: Tile(index: 4, text: 'FAQ', themeColor: themeColor, themeGradient: themeGradient),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class Tile extends StatelessWidget {
  final int index;
  final String text;
  final Color themeColor;
  final GradientColorOption? themeGradient;

  const Tile({
    Key? key,
    required this.index,
    required this.text,
    required this.themeColor,
    this.themeGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            switch (index) {
              case 0:
                return const MissionScreen();
              case 1:
                return const TeamScreen();
              case 2:
                return const ContactScreen();
              case 3:
                return const PrivacyScreen();
              case 4:
                return const FaqScreen();
              default:
                return const AboutUsScreen();
            }
          }),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: themeGradient != null ? themeGradient!.gradient : null,
          color: themeGradient == null ? getShade(index) : null,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Raleway',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Function to get different shades of the provided color
  Color getShade(int index) {
    List<Color> shades = [
      themeColor,
      themeColor.withOpacity(0.9),
      themeColor.withOpacity(0.8),
      themeColor.withOpacity(0.7),
      themeColor.withOpacity(0.6),
    ];
    return shades[index % shades.length];
  }
}
