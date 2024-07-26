import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip_card/flip_card.dart';
import '../theme/theme.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);

  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  int? selectedIndex;
  List<bool> isFrontList = [true, true, true, true];
  List<GlobalKey<FlipCardState>> cardKeys = [
    GlobalKey<FlipCardState>(),
    GlobalKey<FlipCardState>(),
    GlobalKey<FlipCardState>(),
    GlobalKey<FlipCardState>(),
  ];
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
          'Meet the Team',
          style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() {
            selectedIndex = null;
          });
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: _buildCards(),
                ),
              ),
              const SizedBox(height: 40), // Adjust space to position the button higher
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
                  style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Raleway'),
                ),
              ),
              const SizedBox(height: 20), // Add some space between the button and the bottom
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  List<Widget> _buildCards() {
    List<Widget> cards = [];
    for (int index = 0; index < 4; index++) {
      int offset = index - 1;
      bool isSelected = selectedIndex == index;

      Widget card = AnimatedPositioned(
        key: ValueKey(index),
        duration: const Duration(milliseconds: 500),
        left: isSelected
            ? MediaQuery.of(context).size.width / 2 - 105 // Adjusted for bigger size
            : MediaQuery.of(context).size.width / 2 - 70 + offset * 60.0,
        top: isSelected
            ? MediaQuery.of(context).size.height / 2 - 157.5 // Adjusted for bigger size
            : MediaQuery.of(context).size.height / 2 - 105,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedIndex = null;
              } else {
                selectedIndex = index;
              }
            });
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 500),
            scale: isSelected ? 1.5 : 1.0,
            child: Transform(
              transform: Matrix4.identity()
                ..rotateZ(isSelected ? 0 : offset * 5 * 3.1415927 / 180),
              origin: const Offset(70, 105),
              child: ImageCard(
                key: cardKeys[index],
                isSelected: isSelected,
                frontImagePath: 'assets/images/front${index + 1}.png',
                isFront: isFrontList[index],
                onFlipDone: (isFront) {
                  setState(() {
                    isFrontList[index] = isFront;
                  });
                },
              ),
            ),
          ),
        ),
      );

      if (isSelected) {
        cards.add(card);
      } else {
        cards.insert(0, card);
      }
    }
    return cards;
  }
}

class ImageCard extends StatefulWidget {
  final bool isSelected;
  final String frontImagePath;
  final bool isFront;
  final ValueChanged<bool> onFlipDone;

  const ImageCard({
    Key? key,
    required this.isSelected,
    required this.frontImagePath,
    required this.isFront,
    required this.onFlipDone,
  }) : super(key: key);

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  late bool isFront;
  late GlobalKey<FlipCardState> cardKey;

  @override
  void initState() {
    super.initState();
    isFront = widget.isFront;
    cardKey = GlobalKey<FlipCardState>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isSelected ? 210 : 140, // Adjusted for bigger size
      height: widget.isSelected ? 315 : 210, // Adjusted for bigger size
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlipCard(
          key: cardKey,
          flipOnTouch: widget.isSelected,
          direction: FlipDirection.HORIZONTAL,
          onFlipDone: (isFront) {
            setState(() {
              this.isFront = isFront;
              widget.onFlipDone(isFront);
            });
          },
          front: Image.asset(
            'assets/images/back.png',
            fit: BoxFit.cover,
          ),
          back: Image.asset(
            widget.frontImagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
