// logo_widget.dart
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final IconData icon;
  const Logo(this.icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 36.0, // Adjust size as needed
    );
  }
}
