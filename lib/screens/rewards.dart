import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';

import 'package:flutter_app/models/light_mode.dart';

class RewardsPage extends StatelessWidget {
  RewardsPage({super.key});
  final userEmail =
      authServiceNotifier.value.currentUser?.email ?? 'Email not found';

  Future<String> _fetchName(String userEmail) async {
    Map<String, dynamic>? userProfile = await DatabaseService().getDataByEmail(
      email: userEmail,
      path: Words.profileData,
    );

    if (userProfile != null) {
      String firstName = userProfile[Words.profilefn] ?? 'Name unknown';

      return firstName.toString();
    } else {
      return 'Name unknown';
    }
  }

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
                FutureBuilder<String>(
                  future: _fetchName(userEmail),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Text(
                            'Welcome ${snapshot.data}!',
                            style: const TextStyle(fontSize: 24),
                          );
                        } else {
                          return const Text('Welcome!');
                        }
                      },
                ),
                SizedBox(height: 20),
                Text('Information about your Rewards!'),
                SizedBox(height: 20),
                ClipRRect(
                  // The value (e.g., 8.0) controls how rounded the corners are.
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/Rewards_participant.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit
                        .cover, // Optional: ensures the image fills the space
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(
                    20.0,
                  ), // <- Fixed: Use EdgeInsets.all()
                  child: Text(
                    'A heartfelt thank you for volunteering in our Community.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
