import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle titleText = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: Colors.teal,
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: Colors.red,
  );

  static const InputDecoration textFieldDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(color: Colors.teal, width: 2),
    ),
  );

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );
}