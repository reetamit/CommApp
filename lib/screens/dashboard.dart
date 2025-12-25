import 'package:flutter/material.dart';
import 'package:flutter_app/models/gradient_theme.dart';
import 'package:flutter_app/screens/events/eventsPage.dart';
import 'package:flutter_app/screens/aboutus.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/screens/auth/loginpage.dart';
import 'package:flutter_app/screens/volunteer/message.dart';
import 'package:flutter_app/screens/auth/profile.dart';
import 'package:flutter_app/screens/volunteer/request.dart';
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
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppGradients.light),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      bottomNavigationBar: Stack(
        children: <Widget>[
          // The gradient container is the first child
          Container(
            height: 100, // Match the height of the BottomNavigationBar
            decoration: const BoxDecoration(gradient: AppGradients.light),
          ),
          BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0, // Remove the shadow
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
              BottomNavigationBarItem(
                icon: Icon(Icons.email),
                label: 'Messages',
              ),
              //BottomNavigationBarItem(
              //  icon: Icon(Icons.settings),
              //  label: 'Settings',
              //),
            ],
          ),
        ],
      ),

      drawer: Drawer(
        width: 220.0,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 120.00,
              child: const DrawerHeader(
                decoration: BoxDecoration(gradient: AppGradients.light),
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
