import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/event.dart';
import 'package:flutter_app/models/gradient_theme.dart';
import 'package:intl/intl.dart';

class EventEditScreen extends StatefulWidget {
  final Event event;

  const EventEditScreen({super.key, required this.event});

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime? selectedDate;
  final List<String> _categories = ['Tutor', 'Cleaning', 'Health Care'];

  // Fetch user profile details
  final userEmail =
      authServiceNotifier.value.currentUser?.email ?? 'Email not found';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.event.dateTime;
    _descriptionController.text = widget.event.description;
    _selectedCategory = widget.event.title;
  }

  void _deleteRequest(String key) async {
    // Add logic to delete the request from the database
    // For example, using your DatabaseService:
    await DatabaseService().delete(path: '${Words.eventPath}/$key');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Event deleted.')));
    Navigator.of(context).pop();
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

  void _showDeleteConfirmationDialog(String key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Do you really want to delete your request? This action cannot be undone.',
          ),
          actions: <Widget>[
            // Cancel Button
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            // Confirmation Button
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _deleteRequest(key); // Call the delete function
              },
            ),
          ],
        );
      },
    );
  }

  void _editEvent(String key) async {
    // Check if the user is the request's owner
    if (userEmail == widget.event.email) {
      Map<String, dynamic>? eventData = await DatabaseService().getDataByEmail(
        email: userEmail,
        path: Words.eventPath,
      );
      if (eventData != null) {
        await DatabaseService().update(
          path:
              '${Words.eventPath}/$key', // Correctly targets the specific request
          data: {
            Words.eventDesc: _descriptionController.text,
            Words.eventType: _selectedCategory,
            Words.eventTimestamp:
                selectedDate?.toIso8601String() ??
                DateTime.now().toIso8601String(),
          },
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Event is updated')));
        //_responseController.clear();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.event;
    final isOwner = userEmail == req.email;
    return Scaffold(
      appBar: AppBar(
        title: Text(isOwner ? 'Event Edit Screen' : 'Respond to Request'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppGradients.light),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.left,
              'You can change your category',
              style: TextStyle(fontSize: 16),
            ),

            // Dropdown list
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
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
                  child: const Text('Change Date'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                //labelText: req.description,
              ),
              maxLines: 3,
            ),
            //Text(req.description),
            const SizedBox(height: 12),
            Text(
              'Event date : ${DateFormat.yMMMd().format(req.dateTime.toLocal())}',
            ),
            const SizedBox(height: 16),
            // Conditionally show the Delete or Send Response button
            if (isOwner) ...[
              ElevatedButton(
                onPressed: () => _editEvent(req.key),
                child: const Text('Save your change'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(
                    req.key,
                  ); // Show confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(
                    150,
                    50,
                  ), // Set a minimum width and height
                  maximumSize: const Size(
                    300,
                    80,
                  ), // Set a maximum width and height // Make the button red
                ),
                child: const Text('Delete Event'),
              ),
            ],
            //else
          ],
        ),
      ),
    );
  }
}
