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
  bool _showAnswer = false;
  bool _isShuffled = false;

  void _nextCard() {
    setState(() {
      if (_showAnswer) {
        _showAnswer = false;
        if (currentIndex < widget.flashcards.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }
      } else {
        _showAnswer = true;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
      _showAnswer = false;
    });
  }

  void _togglePlay() {
    if (_isPlaying) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(Duration(seconds: 3), (timer) {
        _nextCard();
      });
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _shuffleCards() {
    setState(() {
      widget.flashcards.shuffle();
      currentIndex = 0;
      _isShuffled = true;
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
        title: Text('Practice Cards'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(widget.setTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${currentIndex + 1} / ${widget.flashcards.length}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
            SizedBox(height: 20),
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
              flipOnTouch: !_isPlaying,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  color: _isPlaying ? Colors.green : Colors.black,
                  onPressed: _togglePlay,
                ),
                IconButton(
                  icon: Icon(Icons.shuffle),
                  color: _isShuffled ? Colors.green : Colors.black,
                  onPressed: _shuffleCards,
                ),
              ],
            ),
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
