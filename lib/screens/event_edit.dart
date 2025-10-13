import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/event.dart';
import 'package:intl/intl.dart';
import '../models/request.dart';

class EventEditScreen extends StatefulWidget {
  final Event event;

  const EventEditScreen({super.key, required this.event});

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  // Fetch user profile details
  final userEmail =
      authServiceNotifier.value.currentUser?.email ?? 'Email not found';

  @override
  void dispose() {
    super.dispose();
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

  // Inside your _RequestResponseScreenState class

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
            Words.eventDesc: userEmail,
            Words.eventType: 'type',
            Words.eventTimestamp: 'datetime',
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
        title: Text(isOwner ? 'Your request' : 'Respond to Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              req.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(req.description),
            const SizedBox(height: 12),
            Text(
              'Requested at: ${DateFormat.yMMMd().add_jm().format(req.dateTime.toLocal())}',
            ),
            const SizedBox(height: 16),
            // Conditionally show the Delete or Send Response button
            if (isOwner) ...[
              ElevatedButton(
                onPressed: () => _editEvent(req.key),
                child: const Text('Edit Event'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(
                    req.key,
                  ); // Show confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Make the button red
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
