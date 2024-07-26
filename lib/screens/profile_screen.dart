import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/theme.dart';

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
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  String? _savedPassword;
  Color themeColor = lightColorScheme.primary;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _loadProfileData();
    _loadThemeColor();
  }

  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final int colorValue = prefs.getInt('theme_color') ?? lightColorScheme.primary.value;
      themeColor = Color(colorValue);
    });
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _profileImagePath = prefs.getString('profile_image');
      _savedPassword = prefs.getString('password');
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
          title: const Text('Success'),
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
          title: const Text('Error'),
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
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$"
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'Please enter a valid name';
    }
    if (value.length < 3) {
      return 'Full name must be at least 3 characters long';
    }
    return null;
  }

  String? _validateOldPassword(String? value) {
    if (_newPasswordController.text.isNotEmpty) {
      if (value == null || value.isEmpty) {
        return 'Please enter your old password';
      }
      if (_savedPassword != value) {
        return 'Old password is incorrect';
      }
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No need to validate if it's empty
    }
    if (value.length < 8) {
      return 'New password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'New password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'New password must contain at least one number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
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
                            fit: BoxFit.contain,
                          )
                        : null,
                    color: Colors.grey[300],
                  ),
                  child: _profileImagePath == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                ),
                validator: _validateFullName,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOldPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureOldPassword,
                validator: _validateOldPassword,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureNewPassword,
                validator: _validateNewPassword,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveProfileData,
                child: const Text('Save Profile', style: TextStyle(fontFamily: 'Raleway')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
