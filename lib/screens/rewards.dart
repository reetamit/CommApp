import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/gradient_theme.dart';
import 'package:flutter_app/models/light_mode.dart';

// 1. Change to a StatefulWidget
class RewardsPage extends StatefulWidget {
  RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final userEmail =
      authServiceNotifier.value.currentUser?.email ?? 'Email not found';

  // State variables to hold the fetched data
  String _firstName = 'Loading...';
  int _rewardsCount = 0;
  bool _isLoading = true; // To track the loading state
  String? _error; // To hold any error messages

  // 2. Move the data fetching logic here
  Future<void> _fetchData() async {
    try {
      Map<String, dynamic>? userProfile = await DatabaseService()
          .getDataByEmail(email: userEmail, path: Words.profileData);

      if (userProfile != null) {
        // Use setState() to update the UI
        setState(() {
          _firstName = userProfile[Words.profilefn] ?? 'Name unknown';
          _rewardsCount = userProfile[Words.profilecc] ?? 0;
          _isLoading = false; // Data is loaded
        });
      } else {
        setState(() {
          _error = 'User profile not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

  // 3. Call the fetch function in initState()
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Use the state variables directly in the build method
    String rewardMessage;
    String rewardImage;
    if (_rewardsCount > 100) {
      rewardImage = 'assets/images/Rewards_Master.png';
      rewardMessage =
          'You are a rewards master for volunteering more than 100 times. Keep up the great work.';
    } else if (_rewardsCount > 50) {
      rewardImage = 'assets/images/Rewards50.png';
      rewardMessage = 'Amazing! You\'ve reached over 50 volunteering!';
    } else if (_rewardsCount > 10) {
      rewardImage = 'assets/images/Rewards10.png';
      rewardMessage = 'Great work! You have volunteered more than 10 times.';
    } else {
      rewardImage = 'assets/images/Rewards_Default.png';
      rewardMessage = 'Thank you for your participation.';
    }

    return Theme(
      data: lightMode,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rewards'),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: AppGradients.light),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _isLoading
                ? const CircularProgressIndicator() // Show a loading indicator
                : _error != null
                ? Text('Error: $_error') // Show error if it occurred
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Congratulations $_firstName!',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 10),
                      Text(rewardMessage), // Use the determined message
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          rewardImage,
                          width: 300,
                          height: 500,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          rewardMessage,
                          style: TextStyle(fontSize: 15),
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
