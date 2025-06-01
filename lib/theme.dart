import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: AppColors.darkNavy,
        primaryColor: AppColors.deepPurple,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.deepPurple,
          secondary: AppColors.mintGreen,
          surface: AppColors.darkNavy,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.deepPurple,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mintGreen,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // You can add more theme customizations here as needed
      );

  static Color get userBubble => AppColors.deepPurple.withAlpha((0.2 * 255).round());
  static Color get aiBubble => AppColors.glassWhite.withAlpha((0.7 * 255).round());
  static Color get chatText => Colors.white;
}
