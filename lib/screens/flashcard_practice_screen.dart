import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../models/flashcard.dart';

class FlashcardPracticeScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String setTitle;

  const FlashcardPracticeScreen({Key? key, required this.flashcards, required this.setTitle}) : super(key: key);

  @override
  _FlashcardPracticeScreenState createState() => _FlashcardPracticeScreenState();
}

class _FlashcardPracticeScreenState extends State<FlashcardPracticeScreen> {
  int currentIndex = 0;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isNext = true;
  bool _showAnswer = false;

  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  late List<Flashcard> _originalFlashcards;

  @override
  void initState() {
    super.initState();
    _originalFlashcards = List.from(widget.flashcards);
  }

  void _nextCard() {
    setState(() {
      _isNext = true;
      if (currentIndex < widget.flashcards.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      _showAnswer = false;
    });
  }

  void _previousCard() {
    setState(() {
      _isNext = false;
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = widget.flashcards.length - 1;
      }
      _showAnswer = false;
    });
  }

  void _togglePlay() {
    if (_isPlaying) {
      _timer?.cancel();
    } else {
      _startAutoPlay();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_showAnswer) {
        // Ensure the card is showing the question before moving to the next card
        if (cardKey.currentState != null && cardKey.currentState!.isFront != true) {
          cardKey.currentState?.toggleCard();
          await Future.delayed(Duration(milliseconds: 500)); // Wait for the flip animation
        }
        _nextCard();
      } else {
        cardKey.currentState?.toggleCard(); // Flip to show the answer
        setState(() {
          _showAnswer = true;
        });
      }
    });

    // Initial delay to show the question for 5 seconds before the first flip
    Future.delayed(Duration(seconds: 5), () {
      if (_isPlaying) {
        cardKey.currentState?.toggleCard(); // Flip to show the answer
        setState(() {
          _showAnswer = true;
        });
      }
    });
  }

  void _shuffleCards() {
    setState(() {
      if (_isShuffled) {
        widget.flashcards
          ..clear()
          ..addAll(_originalFlashcards);
        _isShuffled = false;
      } else {
        widget.flashcards.shuffle();
        _isShuffled = true;
      }
      currentIndex = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentIndex + 1) / widget.flashcards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Cards', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(widget.setTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Raleway')),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${currentIndex + 1} / ${widget.flashcards.length}', style: TextStyle(fontSize: 13, fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
            SizedBox(height: 20),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200), // Faster animation
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                        begin: _isNext ? Offset(1.0, 0.0) : Offset(-1.0, 0.0),
                        end: Offset(0.0, 0.0))
                    .animate(animation);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              child: FlipCard(
                key: cardKey,
                direction: FlipDirection.HORIZONTAL,
                flipOnTouch: !_isPlaying,
                front: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      width: 300,
                      height: 400,
                      padding: EdgeInsets.all(16), // Add padding
                      child: Center(
                        child: Text(
                          widget.flashcards[currentIndex].question,
                          style: TextStyle(fontSize: 18, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                back: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      width: 300,
                      height: 400,
                      padding: EdgeInsets.all(16), // Add padding
                      child: Center(
                        child: Text(
                          widget.flashcards[currentIndex].answer,
                          style: TextStyle(fontSize: 16, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  color: _isPlaying ?Color.fromARGB(255, 200, 155, 87) : Colors.black,
                  onPressed: _togglePlay,
                ),
                IconButton(
                  icon: Icon(Icons.shuffle),
                  color: _isShuffled ?Color.fromARGB(255, 200, 155, 87) : Colors.black,
                  onPressed: _shuffleCards,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousCard,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text('Previous', style: TextStyle(fontFamily: 'Raleway', fontSize: 16)),
                    ),
                  ),
                  SizedBox(width: 16), // Space between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextCard,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text('Next', style: TextStyle(fontFamily: 'Raleway', fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
