import 'package:flutter/material.dart';
import 'package:flutter_app/models/gradient_theme.dart';
import 'package:flutter_app/screens/create_event.dart';
import 'package:flutter_app/screens/ongoing_events.dart';

// The main EventsPage with the BottomNavigationBar
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    OngoingEventsScreen(),
    const EventCreateScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Ongoing Events' : 'Create Event'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppGradients.light),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Stack(
        children: <Widget>[
          // The gradient container is the first child
          Container(
            height: 100, // Match the height of the BottomNavigationBar
            decoration: const BoxDecoration(gradient: AppGradients.light),
          ),
          BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Ongoing Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle),
                label: 'Create Event',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
