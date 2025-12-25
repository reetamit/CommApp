import 'package:flutter/material.dart';
import 'package:flutter_app/models/light_mode.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // Add state variables here
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = ['Tutor', 'Cleaning', 'Health Care'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onCreateEvent() {
    // Handle the event creation logic here,
    // e.g., print the selected category and description
    print('Category: $_selectedCategory');
    print('Description: ${_descriptionController.text}');

    // You can also show a SnackBar for confirmation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Event Created!')));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightMode,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Event')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //const Text('Information about your Events!'),
                //const SizedBox(height: 20),
                // Text for Events 1 (you can remove this if not needed)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Please select your category',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                // Dropdown list
                DropdownButton<String>(
                  hint: const Text('Select a category'),
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: _categories.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Textbox for description
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description of your Event',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 50),
                // "Create Event" button
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: _onCreateEvent,
                      child: const Text('Create Event'),
                    ),
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
