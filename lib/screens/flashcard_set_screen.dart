import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/flashcard.dart';
import 'flashcard_practice_screen.dart'; // Import the practice screen

class FlashcardSetScreen extends StatefulWidget {
  final String setName;
  final Function updateFlashcardsCount;

  const FlashcardSetScreen({Key? key, required this.setName, required this.updateFlashcardsCount}) : super(key: key);

  @override
  _FlashcardSetScreenState createState() => _FlashcardSetScreenState();
}

class _FlashcardSetScreenState extends State<FlashcardSetScreen> {
  List<Flashcard> flashcards = [];
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFlashcards();
  }

  Future<void> _loadUserIdAndFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
      _loadFlashcards();
    });
  }

  Future<void> _loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? flashcardsJson = prefs.getString('flashcards_${widget.setName}_$userId');
    if (flashcardsJson != null) {
      setState(() {
        flashcards = (json.decode(flashcardsJson) as List)
            .map((data) => Flashcard(
                question: data['question'], answer: data['answer']))
            .toList();
      });
      widget.updateFlashcardsCount(); // Notify HomeScreen to update the count
    }
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final String flashcardsJson = json.encode(
        flashcards.map((flashcard) => {'question': flashcard.question, 'answer': flashcard.answer}).toList());
    await prefs.setString('flashcards_${widget.setName}_$userId', flashcardsJson);
    widget.updateFlashcardsCount(); // Notify HomeScreen to update the count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.setName),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: flashcards.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildFlashcardItem(flashcards[index]);
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashcardPracticeScreen(
                        flashcards: flashcards,
                        setTitle: widget.setName, // Pass the setTitle here
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Practice Cards',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addFlashcard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Add Card',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardItem(Flashcard flashcard) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(flashcard.question),
        subtitle: Text(flashcard.answer),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _editFlashcard(flashcard);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteFlashcard(flashcard);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addFlashcard() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String question = '';
        String answer = '';

        return AlertDialog(
          title: Text('Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Question'),
                onChanged: (value) {
                  question = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Answer'),
                onChanged: (value) {
                  answer = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (question.isNotEmpty && answer.isNotEmpty) {
                  setState(() {
                    flashcards.add(Flashcard(question: question, answer: answer));
                  });
                  _saveFlashcards();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editFlashcard(Flashcard flashcard) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedQuestion = flashcard.question;
        String editedAnswer = flashcard.answer;

        return AlertDialog(
          title: Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Question'),
                controller: TextEditingController(text: flashcard.question),
                onChanged: (value) {
                  editedQuestion = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Answer'),
                controller: TextEditingController(text: flashcard.answer),
                onChanged: (value) {
                  editedAnswer = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (editedQuestion.isNotEmpty && editedAnswer.isNotEmpty) {
                  setState(() {
                    flashcard.question = editedQuestion;
                    flashcard.answer = editedAnswer;
                  });
                  _saveFlashcards();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFlashcard(Flashcard flashcard) {
    setState(() {
      flashcards.remove(flashcard);
    });
    _saveFlashcards();
  }
}
