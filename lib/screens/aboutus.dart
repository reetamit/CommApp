import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'This is a sample application developed to demonstrate the dashboard functionality with navigation and user authentication. \n\n'
          'Developed by: Your Company Name\n'
          'Version: 1.0.0\n\n'
          'For more information, visit our website or contact support.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
