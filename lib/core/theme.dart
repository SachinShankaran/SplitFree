import 'package:flutter/material.dart';

class AppTheme {
  // Splitwise-inspired color palette
  static const Color _tealGreen = Color(0xFF5BC5A7);
  static const Color _darkBg = Color(0xFF1A1A1A); // Dark background
  static const Color _darkCardBg = Color(0xFF2A2A2A); // Dark card background
  static const Color _whiteText = Colors.white;
  static const Color _lightGrayText = Color(0xFFB0B0B0);
  static const Color _darkGray = Color(0xFF3A3A3A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _tealGreen,
        brightness: Brightness.dark,
        primary: _tealGreen,
        secondary: _lightGrayText,
        surface: _darkCardBg,
        background: _darkBg,
        error: Colors.red.shade600,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _whiteText,
        onBackground: _whiteText,
      ),
      
      // Dark background
      scaffoldBackgroundColor: _darkBg,
      
      // Dark app bar
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBg,
        foregroundColor: _whiteText,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _whiteText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Splitwise-style buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _tealGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // More rounded like Splitwise
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Secondary buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _tealGreen,
          side: BorderSide(color: _tealGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _tealGreen,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _tealGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input decoration theme for forms
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _tealGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade600, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: _lightGrayText,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: _lightGrayText,
          fontSize: 16,
        ),
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: _lightGrayText,
        size: 24,
      ),
      
      // Text theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: _whiteText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _whiteText,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: _whiteText,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _whiteText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _whiteText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: _whiteText,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: _whiteText,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: _lightGrayText,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: _darkCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: TextStyle(
          color: _whiteText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: _lightGrayText,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: _darkGray,
        thickness: 1,
      ),
    );
  }
  
  // Helper method for creating dark containers (since you can't use cards)
  static BoxDecoration get containerDecoration => BoxDecoration(
    color: _darkCardBg,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  // Helper method for input containers
  static BoxDecoration get inputContainerDecoration => BoxDecoration(
    color: _darkCardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _darkGray, width: 1),
  );
}