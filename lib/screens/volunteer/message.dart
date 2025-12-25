import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/chat_services.dart';
import 'package:flutter_app/models/utility.dart';
import 'package:flutter_app/screens/volunteer/chatpage.dart';

class MessageScreen extends StatelessWidget {
  MessageScreen({Key? key}) : super(key: key);

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Messages')),
      //drawer: const MyDrawer(),
      body: _buildRequestList(),
    );
  }

  Widget _buildRequestList() {
    return StreamBuilder(
      stream: _chatService.fetchUserRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(child: Text('No requests found.'));
        } else {
          final requests = snapshot.data as List<Map<String, dynamic>>;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.grey, // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(
                    8.0,
                  ), // Optional: rounded corners
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ), // Add spacing between items
                child: ListTile(
                  leading: Icon(Icons.chat, color: Colors.grey),
                  title: Text(
                    request[Words.requestType] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Text(
                    request[Words.requestDesc] ?? 'No Description',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${Utility.formatDateTime(request['dateTime']?.toDate() ?? DateTime.now())}\nStatus: ${request[Words.requestStatus] ?? "No Status"}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    // Navigate to chat screen with the selected request
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(receiverId: request[Words.requestUser]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
