import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/chat_services.dart';
import 'package:flutter_app/screens/chatpage.dart';

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
              return ListTile(
                title: Text(request['title'] ?? 'No Title'),
                subtitle: Text(request['description'] ?? 'No Description'),
                trailing: Text(request['status'] ?? 'No Status'),
                onTap: () {
                  // Navigate to chat screen with the selected request
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(receiverId: request['email']),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
