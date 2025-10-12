// gradient_background.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/models/gradient_theme.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDarkMode ? AppGradients.dark : AppGradients.light;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
