import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'flashcard_set_list_screen.dart';
import '../theme/theme.dart';
import '../screens/flashcard_set_screen.dart';
import '../models/flashcard_set.dart';
import '../models/flashcard.dart';
import '../screens/welcome_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'User';
  String userId = '';
  String? profileImagePath;
  int _currentIndex = 0;
  late PageController _pageController;
  late PageController _cardsPageController;
  List<FlashcardSet> flashcardSets = [];
  int totalFlashcards = 0;
  String searchQuery = '';

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
    _loadUserNameAndProfileImage();
    _pageController = PageController(initialPage: _currentIndex);
    _cardsPageController = PageController(initialPage: 1, viewportFraction: 0.5); // Adjust the viewportFraction as needed
  }

  Future<void> _loadUserNameAndProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'User';
      userId = prefs.getString('user_id') ?? '';
      profileImagePath = prefs.getString('profile_image');
      _loadFlashcardSets();
    });
  }

  Future<void> _loadFlashcardSets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? flashcardSetsJson = prefs.getString('flashcard_sets_$userId');
    if (flashcardSetsJson != null) {
      setState(() {
        flashcardSets = (json.decode(flashcardSetsJson) as List)
            .map((data) => FlashcardSet.fromJson(data))
            .toList();
      });
      _loadFlashcardsCount();
    }
  }

  Future<void> _loadFlashcardsCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    for (var set in flashcardSets) {
      final String? flashcardsJson =
          prefs.getString('flashcards_${set.name}_$userId');
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
    final String flashcardSetsJson = json.encode(flashcardSets
        .map((set) => set.toJson())
        .toList());
    await prefs.setString('flashcard_sets_$userId', flashcardSetsJson);
  }

  Future<void> _deleteFlashcardSet(String setName) async {
    setState(() {
      flashcardSets.removeWhere((set) => set.name == setName);
    });
    _saveFlashcardSets();
    _loadFlashcardsCount(); // Update flashcard count
  }

  Future<void> _renameFlashcardSet(String oldName, String newName) async {
    setState(() {
      final index = flashcardSets.indexWhere((set) => set.name == oldName);
      if (index != -1) {
        flashcardSets[index] = flashcardSets[index].copyWith(name: newName);
      }
    });
    _saveFlashcardSets();
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
                      labelStyle: TextStyle(fontFamily: 'Raleway'),
                      errorText: nameExists ? 'Set name already exists' : null,
                      errorStyle: TextStyle(fontFamily: 'Raleway'),
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
                  child: const Text('Cancel', style: TextStyle(fontFamily: 'Raleway')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Create', style: TextStyle(fontFamily: 'Raleway')),
                  onPressed: () {
                    if (setName.isNotEmpty && !nameExists) {
                      setState(() {
                        String creationDate = DateTime.now()
                            .toLocal()
                            .toString()
                            .split(' ')[0];
                        flashcardSets.add(
                            FlashcardSet(name: setName, creationDate: creationDate));
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
      },
    );
  }

  void _showRenameSetDialog(FlashcardSet flashcardSet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _controller =
            TextEditingController(text: flashcardSet.name);
        String setName = flashcardSet.name;
        bool nameExists = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rename Flashcard Set'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'New Set Name',
                      labelStyle: TextStyle(fontFamily: 'Raleway'),
                      errorText: nameExists ? 'Set name already exists' : null,
                      errorStyle: TextStyle(fontFamily: 'Raleway'),
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
                  child: const Text('Cancel', style: TextStyle(fontFamily: 'Raleway')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Rename', style: TextStyle(fontFamily: 'Raleway')),
                  onPressed: () {
                    if (setName.isNotEmpty && !nameExists) {
                      _renameFlashcardSet(flashcardSet.name, setName);
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

  void _showDeleteConfirmationDialog(FlashcardSet flashcardSet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Flashcard Set', style: TextStyle(fontFamily: 'Raleway')),
          content: Text('Do you really want to delete "${flashcardSet.name}"?', style: TextStyle(fontFamily: 'Raleway')),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Raleway')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(fontFamily: 'Raleway')),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFlashcardSet(flashcardSet.name);
              },
            ),
          ],
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

  void _updateFlashcardsCount() {
    _loadFlashcardsCount();
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  List<FlashcardSet> _getFilteredFlashcardSets() {
    if (searchQuery.isEmpty) {
      return flashcardSets;
    } else {
      return flashcardSets
          .where((set) =>
              set.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  void _updateUserName(String newUserName) {
    setState(() {
      userName = newUserName;
    });
  }

  void _updateProfileImage(String? newProfileImagePath) {
    setState(() {
      profileImagePath = newProfileImagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColorScheme.primary,
        title: Text(
          _currentIndex == 0 ? 'Home' : 'Flashcard Sets',
          style: TextStyle(fontFamily: 'Raleway',fontWeight: FontWeight.w800),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                userName,
                style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold,),
              ),
              accountEmail: null,
              currentAccountPicture: profileImagePath != null
                  ? CircleAvatar(
                      backgroundImage: kIsWeb
                          ? NetworkImage(profileImagePath!)
                          : FileImage(File(profileImagePath!))
                              as ImageProvider<Object>,
                    )
                  : CircleAvatar(
                      child: Icon(Icons.account_circle, size: 75),
                    ),
              decoration: BoxDecoration(
                color: lightColorScheme.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.pop(context);
                _pageController.jumpToPage(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('View Flashcard Sets',
                  style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold,)),
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
              title: const Text('Profile',
                  style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      onUserNameChanged: _updateUserName,
                      onProfileImageChanged:
                          _updateProfileImage, // Pass the callback here
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title:
                  const Text('Logout', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold,)),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold,)),
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white, // Light shadow
                                  offset: Offset(-8, -8),
                                  blurRadius: 15,
                                ),
                                BoxShadow(
                                  color: Color(0xFFBEBEBE), // Dark shadow
                                  offset: Offset(8, 8),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'Set',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Raleway',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${flashcardSets.length}',
                                  style: TextStyle(
                                    fontSize: 95,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Raleway',
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white, // Light shadow
                                  offset: Offset(-8, -8),
                                  blurRadius: 15,
                                ),
                                BoxShadow(
                                  color: Color(0xFFBEBEBE), // Dark shadow
                                  offset: Offset(8, 8),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.note,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'Card',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Raleway',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$totalFlashcards',
                                  style: TextStyle(
                                    fontSize: 95,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Raleway',
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
                                  margin: EdgeInsets.all(18.0),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 200, 155, 87),
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white, // Light shadow
                                        offset: Offset(-8, -8),
                                        blurRadius: 15,
                                      ),
                                      BoxShadow(
                                        color: Color(0xFFBEBEBE), // Dark shadow
                                        offset: Offset(8, 8),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        flashcardFacts[factIndex],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Raleway',
                                          color: Colors.white,
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: _onSearchQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search Flashcard Sets...',
                    hintStyle: TextStyle(fontFamily: 'Raleway',fontWeight: FontWeight.w600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                  style: TextStyle(fontFamily: 'Raleway',fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _getFilteredFlashcardSets().length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildFlashcardSetCard(_getFilteredFlashcardSets()[index]);
                  },
                ),
              ),
            ],
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
              icon: Icon(Icons.home, color: _currentIndex == 0 ? Colors.white : Colors.grey),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _pageController.jumpToPage(0);
                });
              },
            ),
            Spacer(flex: 2),
            IconButton(
              icon: Icon(Icons.view_list, color: _currentIndex == 1 ? Colors.white : Colors.grey),
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
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 200, 155, 87), // Background color of the card
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white, // Light shadow
              offset: Offset(-8, -8),
              blurRadius: 15,
            ),
            BoxShadow(
              color: Color(0xFFBEBEBE), // Dark shadow
              offset: Offset(8, 8),
              blurRadius: 15,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome, $userName!',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                'Learn Smarter, Recall Faster', // Replace with the actual email
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardSetCard(FlashcardSet flashcardSet) {
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
                updateFlashcardsCount: _updateFlashcardsCount,
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
            boxShadow: [
              BoxShadow(
                color: Colors.white, // Light shadow
                offset: Offset(-8, -8),
                blurRadius: 15,
              ),
              BoxShadow(
                color: Color(0xFFBEBEBE), // Dark shadow
                offset: Offset(8, 8),
                blurRadius: 15,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Rename', style: TextStyle(fontFamily: 'Raleway')),
                            onTap: () {
                              Navigator.pop(context);
                              _showRenameSetDialog(flashcardSet);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete', style: TextStyle(fontFamily: 'Raleway')),
                            onTap: () {
                              Navigator.pop(context);
                              _showDeleteConfirmationDialog(flashcardSet);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
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
