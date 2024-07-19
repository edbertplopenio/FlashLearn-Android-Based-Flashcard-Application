import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'flashcard_set_list_screen.dart';
import '../theme/theme.dart';
import '../screens/flashcard_set_screen.dart';
import '../models/flashcard_set.dart';
import '../models/flashcard.dart';
import '../screens/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'User';
  String userId = '';
  int _currentIndex = 0;
  late PageController _pageController;
  late PageController _cardsPageController;
  List<FlashcardSet> flashcardSets = [];
  int totalFlashcards = 0;

  final List<String> flashcardFacts = [
    "Flashcards are a powerful tool for memorization.",
    "Using flashcards with images can boost memory retention.",
    "Spaced repetition with flashcards enhances long-term recall.",
    "Flashcards are great for language learning.",
    "Digital flashcards can be used on the go.",
    "Creating your own flashcards can improve understanding.",
    "Flashcards can be used for active recall practice.",
    "You can use flashcards for virtually any subject.",
    "Flashcards help break down complex information into bite-sized pieces.",
    "Using flashcards regularly can improve test scores."
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _pageController = PageController(initialPage: _currentIndex);
    _cardsPageController = PageController(initialPage: 1, viewportFraction: 0.5); // Adjust the viewportFraction as needed
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'User';
      userId = prefs.getString('user_id') ?? '';
      _loadFlashcardSets();
    });
  }

  Future<void> _loadFlashcardSets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? flashcardSetsJson = prefs.getString('flashcard_sets_$userId');
    if (flashcardSetsJson != null) {
      setState(() {
        flashcardSets = (json.decode(flashcardSetsJson) as List)
            .map((data) => FlashcardSet(name: data['name']))
            .toList();
      });
      _loadFlashcardsCount();
    }
  }

  Future<void> _loadFlashcardsCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    for (var set in flashcardSets) {
      final String? flashcardsJson = prefs.getString('flashcards_${set.name}_$userId');
      if (flashcardsJson != null) {
        final List flashcards = json.decode(flashcardsJson);
        count += flashcards.length;
      }
    }
    setState(() {
      totalFlashcards = count;
    });
  }

  Future<void> _saveFlashcardSets() async {
    final prefs = await SharedPreferences.getInstance();
    final String flashcardSetsJson = json.encode(
        flashcardSets.map((set) => {'name': set.name}).toList());
    await prefs.setString('flashcard_sets_$userId', flashcardSetsJson);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token'); // Clear session-related data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
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
                    flashcardSets.add(FlashcardSet(name: setName));
                  });
                  _saveFlashcardSets();
                  _loadFlashcardsCount(); // Update flashcard count
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateFlashcardsCount() {
    _loadFlashcardsCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColorScheme.primary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                userName,
                style: TextStyle(fontFamily: 'Raleway'),
              ),
              accountEmail: null,
              decoration: BoxDecoration(
                color: lightColorScheme.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home', style: TextStyle(fontFamily: 'Raleway')),
              onTap: () {
                Navigator.pop(context);
                _pageController.jumpToPage(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('View Flashcard Sets', style: TextStyle(fontFamily: 'Raleway')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                  _pageController.jumpToPage(1);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile', style: TextStyle(fontFamily: 'Raleway')),
              onTap: () {
                Navigator.pop(context);
                _pageController.jumpToPage(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout', style: TextStyle(fontFamily: 'Raleway')),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About', style: TextStyle(fontFamily: 'Raleway')),
              onTap: () {
                // Navigate to the About screen
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildWelcomeMessageCard(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            height: 150,
                            margin: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 200, 155, 87),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder,
                                  size: 50,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'SETs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Raleway',
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '${flashcardSets.length}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 150,
                            margin: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 200, 155, 87),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note,
                                  size: 50,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'CARDs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Raleway',
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '$totalFlashcards',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 260, // Adjust the height as needed
                      child: Row(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _cardsPageController,
                              itemBuilder: (context, index) {
                                final factIndex = index % flashcardFacts.length;
                                return Container(
                                  margin: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 200, 155, 87),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        flashcardFacts[factIndex],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Raleway',
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ListView.builder(
            itemCount: flashcardSets.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildCard(flashcardSets[index]);
            },
          ),
          Center(
            child: Text(
              'Profile Page Content',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
                color: lightColorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSetDialog,
        tooltip: 'Create Flashcard Set',
        child: const Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 200, 155, 87),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Color.fromARGB(255, 200, 155, 87),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Spacer(),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _pageController.jumpToPage(0);
                });
              },
            ),
            Spacer(flex: 2),
            IconButton(
              icon: Icon(Icons.view_list),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                  _pageController.jumpToPage(1);
                });
              },
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessageCard() {
    return FractionallySizedBox(
      widthFactor: 1, // 100% width of the screen
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WELCOME, $userName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                'Learn Smarter, Recall Faster', // Replace with the actual email
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Raleway',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        color: Color.fromARGB(255, 200, 155, 87), // Background color of the card
      ),
    );
  }

  Widget _buildCard(FlashcardSet flashcardSet) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardSetScreen(
                setName: flashcardSet.name,
                updateFlashcardsCount: _updateFlashcardsCount,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            flashcardSet.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Raleway',
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cardsPageController.dispose();
    super.dispose();
  }
}
