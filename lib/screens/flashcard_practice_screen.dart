import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../models/flashcard.dart';

class FlashcardPracticeScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const FlashcardPracticeScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  _FlashcardPracticeScreenState createState() => _FlashcardPracticeScreenState();
}

class _FlashcardPracticeScreenState extends State<FlashcardPracticeScreen> {
  int currentIndex = 0;

  void _nextCard() {
    setState(() {
      if (currentIndex < widget.flashcards.length - 1) {
        currentIndex++;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Cards'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlipCard(
              direction: FlipDirection.HORIZONTAL,
              front: Card(
                elevation: 4,
                child: Container(
                  width: 300,
                  height: 400,
                  child: Center(
                    child: Text(
                      widget.flashcards[currentIndex].question,
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              back: Card(
                elevation: 4,
                child: Container(
                  width: 300,
                  height: 400,
                  child: Center(
                    child: Text(
                      widget.flashcards[currentIndex].answer,
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousCard,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _nextCard,
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
