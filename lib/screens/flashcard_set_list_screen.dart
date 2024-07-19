import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'flashcard_set_screen.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import '../models/flashcard_set.dart';

class FlashcardSetListScreen extends StatefulWidget {
  final Function updateFlashcardsCount;

  const FlashcardSetListScreen({super.key, required this.updateFlashcardsCount});

  @override
  State<FlashcardSetListScreen> createState() => _FlashcardSetListScreenState();
}

class _FlashcardSetListScreenState extends State<FlashcardSetListScreen> {
  List<FlashcardSet> _flashcardSets = [];

  @override
  void initState() {
    super.initState();
    _loadFlashcardSets();
  }

  Future<void> _loadFlashcardSets() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final String? flashcardSetsJson = prefs.getString('flashcard_sets_$userId');
    if (flashcardSetsJson != null) {
      setState(() {
        _flashcardSets = (json.decode(flashcardSetsJson) as List)
            .map((data) => FlashcardSet(name: data['name']))
            .toList();
      });
    }
  }

  Future<void> _saveFlashcardSets() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final String flashcardSetsJson = json.encode(
        _flashcardSets.map((set) => {'name': set.name}).toList());
    await prefs.setString('flashcard_sets_$userId', flashcardSetsJson);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Your Flashcard Sets',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: lightColorScheme.primary,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _flashcardSets.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_flashcardSets[index].name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _flashcardSets.removeAt(index);
                      });
                      _saveFlashcardSets();
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardSetScreen(
                          setName: _flashcardSets[index].name,
                          updateFlashcardsCount: widget.updateFlashcardsCount,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showCreateSetDialog();
            },
            child: const Text('Create New Set'),
          ),
        ],
      ),
    );
  }

  void _showCreateSetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String setName = '';

        return AlertDialog(
          title: const Text('Create Flashcard Set'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Set Name'),
                onChanged: (value) {
                  setName = value;
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
                if (setName.isNotEmpty) {
                  setState(() {
                    _flashcardSets.add(FlashcardSet(name: setName));
                  });
                  _saveFlashcardSets();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
