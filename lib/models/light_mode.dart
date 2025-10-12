import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF0072c5);
  static const Color secondaryblue = Color(0xFF0096d8);
  static const Color accentGreen = Color(0xFF00ab42);
  // Add as many colors as you need
}

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  ),
  //brightness: Brightness.light,
  //primarySwatch: Colors.blue,
  //scaffoldBackgroundColor: const Color.fromARGB(255, 32, 120, 149),
  appBarTheme: AppBarTheme(
    //backgroundColor: Colors.blue,
    backgroundColor: AppColors.primaryBlue,
    //backgroundColor: Colors.transparent,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      //textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.primaryBlue, // Background color
    selectedItemColor: Colors.white, // Color for selected item
    unselectedItemColor: Colors.black54, // Color for unselected items
    selectedIconTheme: IconThemeData(size: 28), // Style for selected icon
    unselectedIconTheme: IconThemeData(size: 24), // Style for unselected icons
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    showUnselectedLabels: true, // Always show labels
    //type:
    //    BottomNavigationBarType.fixed, // Recommended for fixed background color
  ),
);
