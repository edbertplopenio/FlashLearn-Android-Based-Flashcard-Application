import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final Function(String) onUserNameChanged;
  final Function(String?) onProfileImageChanged; // Add this line

  const ProfileScreen({
    required this.onUserNameChanged,
    required this.onProfileImageChanged, // Add this line
    Key? key,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _profileImagePath;
  final List<String> validImageFormats = ['jpg', 'jpeg', 'png'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _profileImagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    if (_profileImagePath != null) {
      await prefs.setString('profile_image', _profileImagePath!);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    widget.onUserNameChanged(_usernameController.text);
    widget.onProfileImageChanged(_profileImagePath); // Notify HomeScreen of the profile image change
    _showSuccessDialog('Profile information updated successfully');
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    print('Picked file path: ${pickedFile?.path}');
    
    if (pickedFile != null) {
      if (kIsWeb) {
        // Handle web-specific image validation
        final mimeType = pickedFile.mimeType;
        print('File MIME type: $mimeType');
        if (_isValidImageMimeType(mimeType!)) {
          setState(() {
            _profileImagePath = pickedFile.path;
          });
          print('Image format valid');
        } else {
          _showErrorDialog('Invalid image format. Please upload a jpg, jpeg, or png file.');
          print('Invalid image format');
        }
      } else {
        // Handle mobile-specific image validation
        if (_isValidImageFormat(pickedFile.path)) {
          setState(() {
            _profileImagePath = pickedFile.path;
          });
          print('Image format valid');
        } else {
          _showErrorDialog('Invalid image format. Please upload a jpg, jpeg, or png file.');
          print('Invalid image format');
        }
      }
    } else {
      _showErrorDialog('No image selected.');
      print('No image selected');
    }
  }

  bool _isValidImageFormat(String path) {
    final extension = path.split('.').last.toLowerCase();
    return validImageFormats.contains(extension);
  }

  bool _isValidImageMimeType(String mimeType) {
    final validMimeTypes = ['image/jpeg', 'image/png'];
    return validMimeTypes.contains(mimeType);
  }

  Future<void> _showSuccessDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: _profileImagePath != null
                      ? DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(_profileImagePath!)
                              : FileImage(File(_profileImagePath!)) as ImageProvider<Object>,
                          fit: BoxFit.contain,
                        )
                      : null,
                  color: Colors.grey[300],
                ),
                child: _profileImagePath == null
                    ? Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveProfileData,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
