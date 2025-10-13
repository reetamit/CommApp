import 'package:flutter/material.dart';
import 'package:flutter_app/screens/EventsPage.dart';
import 'package:flutter_app/screens/aboutus.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/screens/loginpage.dart';
import 'package:flutter_app/screens/message.dart';
import 'package:flutter_app/screens/profile.dart';
import 'package:flutter_app/screens/request.dart';
import 'package:flutter_app/models/light_mode.dart';
import 'package:flutter_app/screens/rewards.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // Implement your logout logic here, such as:
    // 1. Clearing user data or tokens from shared preferences.
    // 2. Calling a backend service to log out the user.
    // 3. Navigating to the login page.

    // For this example, we will just navigate to a placeholder login page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  final List _pages = [
    // homepage
    HomeScreen(),

    // settings page
    RequestScreen(),

    // messages page
    MessageScreen(),
  ];

  // Add a list for the titles.
  final List<String> _titles = ['Home', 'Requests', 'Messages'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Dashboard')),
      body: _pages[_selectedIndex],
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Home'
              : _selectedIndex == 1
              ? 'Request'
              : 'Messages',
          //: _selectedIndex == 2
          //? 'Messages'
          //: 'Profile',
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        // Add this line to fix the visibility issue
        type: BottomNavigationBarType.fixed,
        onTap: navigateTo,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_sharp),
            label: 'Requests',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.email), label: 'Messages'),
          //BottomNavigationBarItem(
          //  icon: Icon(Icons.settings),
          //  label: 'Settings',
          //),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 130.00,
              child: const DrawerHeader(
                decoration: BoxDecoration(color: AppColors.primaryBlue),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.primaryBlue),
              title: const Text('Home'),
              onTap: () {
                navigateTo(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(
                Icons.volunteer_activism_sharp,
                color: AppColors.primaryBlue,
              ),
              title: const Text('Requests'),
              onTap: () {
                navigateTo(1);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.create, color: AppColors.primaryBlue),
              title: const Text('Events'),
              onTap: () {
                // Navigate to the profile screen
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => EventsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primaryBlue),
              title: const Text('Messages'),
              onTap: () {
                navigateTo(2);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primaryBlue),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to the profile screen
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfileFormScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.auto_awesome,
                color: AppColors.primaryBlue,
              ),
              title: const Text('Rewards'),
              onTap: () {
                // Navigate to the profile screen
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => RewardsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.primaryBlue),
              title: const Text('About Us'),
              onTap: () {
                // Navigate to the profile screen
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => AboutUs()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.primaryBlue),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
