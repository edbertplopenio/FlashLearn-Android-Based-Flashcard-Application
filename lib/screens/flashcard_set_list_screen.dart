import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/flashcard_set.dart';
import 'flashcard_set_screen.dart';

class FlashcardSetListScreen extends StatefulWidget {
  final String userId;
  final Function updateFlashcardsCount;

  const FlashcardSetListScreen({required this.userId, required this.updateFlashcardsCount, Key? key}) : super(key: key);

  @override
  State<FlashcardSetListScreen> createState() => _FlashcardSetListScreenState();
}

class _FlashcardSetListScreenState extends State<FlashcardSetListScreen> {
  List<FlashcardSet> flashcardSets = [];

  @override
  void initState() {
    super.initState();
    _loadFlashcardSets();
  }

  Future<void> _loadFlashcardSets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? flashcardSetsJson = prefs.getString('flashcard_sets_${widget.userId}');
    if (flashcardSetsJson != null) {
      setState(() {
        flashcardSets = (json.decode(flashcardSetsJson) as List)
            .map((data) => FlashcardSet(
                name: data['name'], creationDate: data['creationDate']))
            .toList();
      });
      widget.updateFlashcardsCount();
    }
  }

  Future<void> _saveFlashcardSets() async {
    final prefs = await SharedPreferences.getInstance();
    final String flashcardSetsJson = json.encode(flashcardSets
        .map((set) => {'name': set.name, 'creationDate': set.creationDate})
        .toList());
    await prefs.setString('flashcard_sets_${widget.userId}', flashcardSetsJson);
  }

  void _showCreateSetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String setName = '';
        bool nameExists = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Flashcard Set'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Set Name',
                      errorText:
                          nameExists ? 'Set name already exists' : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        setName = value;
                        nameExists = _checkDuplicateSetName(setName);
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Create'),
                  onPressed: () {
                    if (setName.isNotEmpty && !nameExists) {
                      setState(() {
                        String creationDate =
                            DateTime.now().toLocal().toString().split(' ')[0];
                        flashcardSets.add(
                            FlashcardSet(name: setName, creationDate: creationDate));
                      });
                      _saveFlashcardSets();
                      widget.updateFlashcardsCount();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _checkDuplicateSetName(String setName) {
    for (var set in flashcardSets) {
      if (set.name == setName) {
        return true;
      }
    }
    return false;
  }

  Widget _buildCard(FlashcardSet flashcardSet) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardSetScreen(
                setName: flashcardSet.name,
                updateFlashcardsCount: widget.updateFlashcardsCount,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 200, 155, 87),
                Color.fromARGB(255, 235, 200, 150),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Icon(
                    Icons.folder,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          flashcardSet.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Created on: ${flashcardSet.creationDate}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Raleway',
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: flashcardSets.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildCard(flashcardSets[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSetDialog,
        tooltip: 'Create Flashcard Set',
        child: const Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 200, 155, 87),
        shape: CircleBorder(),
      ),
    );
  }
}
