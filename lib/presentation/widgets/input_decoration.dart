
import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration inputDecoration({
    required String hintText,
    required String labelText,
    required IconData icon,
    Color color = const Color.fromARGB(255, 58, 81, 183),
  }) {
    return InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: color),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
      ),
      hintText: hintText,
      labelText: labelText,
      labelStyle: TextStyle(color: color, fontSize: 18),
      prefixIcon: Icon(icon, color: color),
    );
  }
}