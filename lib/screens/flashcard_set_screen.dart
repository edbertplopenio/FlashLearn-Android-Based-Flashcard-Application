import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/flashcard.dart';
import '../theme/theme.dart';
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
  Color themeColor = lightColorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFlashcards();
    _loadThemeColor();
  }

  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final int colorValue = prefs.getInt('theme_color') ?? lightColorScheme.primary.value;
      themeColor = Color(colorValue);
    });
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
        title: Text(widget.setName, style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 96.0), // Adjust the padding to avoid overlap with buttons
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: flashcards.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildFlashcardItem(flashcards[index]);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: HoverButton(
                      color: themeColor,
                      onPressed: () {
                        if (flashcards.length < 3) {
                          _showMinimumCardsDialog();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardPracticeScreen(
                                flashcards: flashcards,
                                setTitle: widget.setName, // Pass the setTitle here
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Practice Cards',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Raleway',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // Space between buttons
                  Expanded(
                    child: HoverButton(
                      color: themeColor,
                      onPressed: _addFlashcard,
                      child: Text(
                        'Add Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Raleway',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardItem(Flashcard flashcard) {
    return Container(
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: Offset(-5, -5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.grey.shade400,
            offset: Offset(5, 5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              flashcard.question,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                flashcard.answer,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.0,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editFlashcard(flashcard);
                } else if (value == 'delete') {
                  _confirmDeleteFlashcard(flashcard);
                }
              },
              icon: Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                  ),
                ];
              },
            ),
          ),
        ],
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
          title: Text('Add Flashcard', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Question'),
                onChanged: (value) {
                  question = value;
                },
                maxLines: null,
                minLines: 1,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Answer'),
                onChanged: (value) {
                  answer = value;
                },
                maxLines: null,
                minLines: 1,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: themeColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: themeColor)),
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
          title: Text('Edit Flashcard', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Question'),
                controller: TextEditingController(text: flashcard.question),
                onChanged: (value) {
                  editedQuestion = value;
                },
                maxLines: null,
                minLines: 1,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Answer'),
                controller: TextEditingController(text: flashcard.answer),
                onChanged: (value) {
                  editedAnswer = value;
                },
                maxLines: null,
                minLines: 1,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: themeColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: themeColor)),
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

  void _confirmDeleteFlashcard(Flashcard flashcard) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Flashcard', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete this flashcard?', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: themeColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: themeColor)),
              onPressed: () {
                setState(() {
                  flashcards.remove(flashcard);
                });
                _saveFlashcards();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMinimumCardsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not enough flashcards', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          content: Text('You need at least 3 flashcards to start practicing.', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, color: themeColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class HoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;

  const HoverButton({Key? key, required this.onPressed, required this.child, required this.color}) : super(key: key);

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovering(true),
      onExit: (_) => _setHovering(false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: widget.color,
                    blurRadius: 20.0,
                    spreadRadius: 1.0,
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }

  void _setHovering(bool hovering) {
    setState(() {
      _hovering = hovering;
    });
  }
}
