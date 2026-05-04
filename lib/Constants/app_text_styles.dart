import 'package:flutter/material.dart';

class AppTextStyles {
  static const double largeTitleSize = 40.0;
  static const double pageTitleSize = 32.0;
  static const double buttonTextSize = 18.0;

  static const TextStyle textStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  static const TextStyle cardViewTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle cardViewScoreValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  static ButtonStyle squareButtonStyle = ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero, // 👈 removes rounding
    ),
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  );
}
