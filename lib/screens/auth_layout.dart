import 'package:flutter/material.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/screens/dashboard.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/screens/app_loading_page.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authServiceNotifier,
      builder: (context, authServiceNotifier, child) {
        return StreamBuilder(
          stream: authServiceNotifier.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = AppLoadingPage();
            } else if (snapshot.hasData) {
              widget = const DashboardPage();
            } else {
              widget = pageIfNotConnected ?? HomeScreen();
            }
            return widget;
          },
        );
      },
    );
  }
}
