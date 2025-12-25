import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final List<String> _types = ['Heath Care', 'Tutoring', 'Cleaning'];
  String _selectedType = 'Heath Care';
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _createRequest() async {
    final userEmail =
        authServiceNotifier.value.currentUser?.email ?? 'Email not found';
    // Handle request creation logic here
    final type = _selectedType;
    final desc = _descController.text;
    String defaultStatus = 'New';

    Map<String, dynamic> requestData = {
      Words.requestType: type,
      Words.requestDesc: desc,
      Words.requestStatus: defaultStatus,
      Words.requestUser: userEmail,
      Words.requestTimestamp: DateTime.now().toIso8601String(),
    };
    try {
      await DatabaseService().create(
        path: Words.requestData,
        data: requestData,
      );
      // You can show a snackbar or dialog for confirmation
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request Created: $type - $desc')));
    } catch (e) {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating request: $e')));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Create Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    _createRequest();
                    //Navigator.of(
                    //  context,
                    //).push(MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Text('Create Request'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
