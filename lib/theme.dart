import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.grey),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.grey,
          thickness: 1,
        ),
        iconTheme: const IconThemeData(color: Colors.blue),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
          bodySmall: TextStyle(color: Colors.grey, fontSize: 14),
          titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      );

  static Color get userBubble => Colors.blue[200]!;
  static Color get aiBubble => Colors.grey[300]!;
  static Color get chatText => Colors.black87;
}
