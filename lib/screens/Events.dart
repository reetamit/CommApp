import 'package:flutter/material.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/light_mode.dart';

class EventsScreen extends StatelessWidget {
  EventsScreen({super.key});
  final userEmail =
      authServiceNotifier.value.currentUser?.email ?? 'Email not found';
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightMode,
      child: Scaffold(
        appBar: AppBar(title: const Text('Rewards')),
        body: Center(
          child: Padding(
            // <- The 'child' argument was missing here
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Information about your Events!'),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(
                    20.0,
                  ), // <- Fixed: Use EdgeInsets.all()
                  child: Text('Events 1', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
