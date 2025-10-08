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
  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _sendResponse(String key) async {
    // Fetch user profile details
    final userEmail =
        authServiceNotifier.value.currentUser?.email ?? 'Email not found';
    Map<String, dynamic>? userProfile = await DatabaseService().getDataByEmail(
      email: userEmail,
      path: Words.profileData,
    );

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a response')));
      //return;
    }

    // For now just show a confirmation. In a real app you'd call an API.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Response sent: $text')));
    _responseController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    return Scaffold(
      appBar: AppBar(title: const Text('Respond to Request')),
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
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              items: _types
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              decoration: InputDecoration(
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

            SizedBox(height: 16),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _sendResponse(req.key);
              },
              child: const Text('Send Response'),
            ),
          ],
        ),
      ),
    );
  }
}
