import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'welcome_screen.dart'; // Import the WelcomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  late final AnimationController _positionController;
  late final AnimationController _flipController;
  late final AnimationController _sizeController;
  late final AnimationController _textOpacityController;
  late final AnimationController _transitionController;
  late final Animation<double> _positionAnimation;
  late final Animation<double> _sizeAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _textOpacityAnimation;
  late final Animation<double> _transitionAnimation;

  @override
  void initState() {
    super.initState();

    _positionController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _sizeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _textOpacityController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _transitionController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _positionAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _positionController,
        curve: Curves.easeOut,
      ),
    );

    _sizeAnimation = Tween<double>(begin: 1.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _sizeController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _sizeController,
        curve: Curves.easeInOut,
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _sizeController,
        curve: Curves.easeInOut,
      ),
    );

    _transitionAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOut,
      ),
    );

    _positionController.forward().then((_) {
      Future.delayed(Duration.zero, () {
        cardKey.currentState?.toggleCard();
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        cardKey.currentState?.toggleCard();
      });

      Future.delayed(const Duration(milliseconds: 3000), () {
        _sizeController.forward();
        _textOpacityController.forward();
      });

      Future.delayed(const Duration(seconds: 4), () {
        _transitionController.forward().then((_) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const WelcomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    _positionController.dispose();
    _flipController.dispose();
    _sizeController.dispose();
    _textOpacityController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: AnimatedBuilder(
          animation: _positionController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_positionAnimation.value * MediaQuery.of(context).size.width, 0),
              child: Center(
                child: AnimatedBuilder(
                  animation: _sizeController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _sizeAnimation.value,
                      child: FlipCard(
                        key: cardKey,
                        flipOnTouch: false,
                        front: _buildImageCard('assets/images/face.png', 'FlashLearn'),
                        back: _buildImageCardWithOpacity('assets/images/back.png'),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath, String text) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 125,
        height: 195,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.contain,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _textOpacityController,
            builder: (context, child) {
              return Opacity(
                opacity: _textOpacityAnimation.value,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageCardWithOpacity(String imagePath) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 125,
        height: 195,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.contain,
          ),
        ),
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 125,
                height: 195,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
