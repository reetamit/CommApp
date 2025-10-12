// gradient_themes.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/models/light_mode.dart';

enum AppThemeMode { light, dark }

class AppGradients {
  static const LinearGradient light = LinearGradient(
    colors: [AppColors.accentGreen, AppColors.primaryBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient dark = LinearGradient(
    colors: [Colors.black, Color.fromARGB(255, 34, 0, 53)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
