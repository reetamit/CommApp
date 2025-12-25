import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/light_mode.dart';

class EventCreateScreen extends StatefulWidget {
  const EventCreateScreen({super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateState();
}

class _EventCreateState extends State<EventCreateScreen> {
  // Add state variables here
  String? _selectedCategory;
  DateTime? selectedDate;
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Tutor',
    'Cleaning',
    'Health Care',
    'Outreach',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  void _onCreateEvent() async {
    final userEmail =
        authServiceNotifier.value.currentUser?.email ?? 'Email not found';
    // Handle request creation logic here
    final type = _selectedCategory;
    final desc = _descriptionController.text;
    String defaultStatus = 'New';

    Map<String, dynamic> eventData = {
      Words.eventType: type,
      Words.eventDesc: desc,
      Words.eventStatus: defaultStatus,
      Words.eventUser: userEmail,
      Words.eventTimestamp:
          selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
    try {
      await DatabaseService().create(path: Words.eventPath, data: eventData);
      // You can show a snackbar or dialog for confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New Event Created: $type - $desc')),
      );
    } catch (e) {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating event: $e')));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightMode,
      child: Scaffold(
        //appBar: AppBar(title: const Text('Create Event')),
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: <Widget>[
                    Text(
                      selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'No date selected',
                    ),
                    OutlinedButton(
                      onPressed: _selectDate,
                      child: const Text('Select Date'),
                    ),
                  ],
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
