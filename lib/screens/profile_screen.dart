import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final Function(String) onUserNameChanged;
  final Function(String?) onProfileImageChanged;

  const ProfileScreen({
    required this.onUserNameChanged,
    required this.onProfileImageChanged,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  String? _profileImagePath;
  final List<String> validImageFormats = ['jpg', 'jpeg', 'png'];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
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
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _usernameController.text);
      await prefs.setString('email', _emailController.text);
      if (_profileImagePath != null) {
        await prefs.setString('profile_image', _profileImagePath!);
      }
      if (_newPasswordController.text.isNotEmpty) {
        await prefs.setString('password', _newPasswordController.text);
      }
      widget.onUserNameChanged(_usernameController.text);
      widget.onProfileImageChanged(_profileImagePath);
      _showSuccessDialog('Profile information updated successfully');
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final mimeType = pickedFile.mimeType;
        if (_isValidImageMimeType(mimeType!)) {
          setState(() {
            _profileImagePath = pickedFile.path;
          });
        } else {
          _showErrorDialog('Invalid image format. Please upload a jpg, jpeg, or png file.');
        }
      } else {
        if (_isValidImageFormat(pickedFile.path)) {
          setState(() {
            _profileImagePath = pickedFile.path;
          });
        } else {
          _showErrorDialog('Invalid image format. Please upload a jpg, jpeg, or png file.');
        }
      }
    } else {
      _showErrorDialog('No image selected.');
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
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Full name must be at least 3 characters long';
    }
    return null;
  }

  String? _validateOldPassword(String? value) {
    final prefs = SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      return 'Please enter your old password';
    }
    if (prefs.then((prefs) => prefs.getString('password')) != value) {
      return 'Old password is incorrect';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 6) {
      return 'New password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontFamily: 'Raleway')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                            fit: BoxFit.cover,
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
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(fontFamily: 'Raleway'),
                ),
                validator: _validateFullName,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontFamily: 'Raleway'),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(fontFamily: 'Raleway'),
                ),
                obscureText: true,
                validator: _validateOldPassword,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(fontFamily: 'Raleway'),
                ),
                obscureText: true,
                validator: _validateNewPassword,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveProfileData,
                child: Text('Save Profile', style: TextStyle(fontFamily: 'Raleway')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
