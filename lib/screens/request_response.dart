import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:intl/intl.dart';
import '../models/request.dart';

class RequestResponseScreen extends StatefulWidget {
  final Request request;

  const RequestResponseScreen({super.key, required this.request});

  @override
  State<RequestResponseScreen> createState() => _RequestResponseScreenState();
}

class _RequestResponseScreenState extends State<RequestResponseScreen> {
  final TextEditingController _responseController = TextEditingController();
  final List<String> _types = ['Responded', 'Completed'];
  String _selectedType = 'Responded';
  // Fetch user profile details
  final userEmail =
      authServiceNotifier.value.currentUser?.email ?? 'Email not found';

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _deleteRequest(String key) async {
    // Add logic to delete the request from the database
    // For example, using your DatabaseService:
    await DatabaseService().delete(path: '${Words.requestData}/$key');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Request deleted.')));
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

  void _sendResponse(String key) async {
    // Check if the user is the request's owner
    if (userEmail == widget.request.email) {
      // Logic for request owner.
      // E.g., The owner might just be able to complete or delete the request.
      // Maybe prevent them from "responding" to their own request.
    } else {
      // Logic for a volunteer responding to a request
      Map<String, dynamic>? userProfile = await DatabaseService()
          .getDataByEmail(email: userEmail, path: Words.profileData);
      // Now you have userProfile and requestId, you can proceed with your logic
      // For example, you might want to include the user's name in the response
      //Update status of the request to 'Responded'
      await DatabaseService().update(
        path:
            '${Words.requestData}/$key', // Correctly targets the specific request
        data: {
          Words.requestStatus: _selectedType,
          Words.requestVolunteer: userEmail,
        },
      );

      final text = _responseController.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a response')),
        );
        //return;
      }

      // For now just show a confirmation. In a real app you'd call an API.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Response sent: $text')));
      _responseController.clear();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
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

            // Show the dropdown and text field only if the user is not the owner
            if (!isOwner) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: _types
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _responseController,
                decoration: const InputDecoration(
                  labelText: 'Your response',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],

            SizedBox(height: 16),
            const Spacer(),

            // Conditionally show the Delete or Send Response button
            if (isOwner)
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(
                    req.key,
                  ); // Show confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Make the button red
                ),
                child: const Text('Delete Request'),
              )
            else
              ElevatedButton(
                onPressed: () => _sendResponse(req.key),
                child: const Text('Send Response'),
              ),
          ],
        ),
      ),
    );
  }
}
