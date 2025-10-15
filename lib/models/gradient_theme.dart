// gradient_themes.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_app/models/light_mode.dart';

enum AppThemeMode { light, dark }

class AppGradients {
  static const LinearGradient light = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.accentGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    transform: GradientRotation(math.pi / 1.2),
  );

  static const LinearGradient dark = LinearGradient(
    colors: [Colors.black, Color.fromARGB(255, 34, 0, 53)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
