import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/chat_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/gradient_theme.dart';
import 'package:flutter_app/models/light_mode.dart';

class ChatScreen extends StatelessWidget {
  final String receiverId;

  ChatScreen({required this.receiverId});

  //Text editing controller for the message input field
  final TextEditingController _messageController = TextEditingController();
  //Chat and auth services
  final ChatService _chatService = ChatService();
  // Get the current user's email
  String currentUser =
      authServiceNotifier.value.currentUser?.email ?? 'Email not found';

  Future<String> _fetchName() async {
    final userEmail =
        authServiceNotifier.value.currentUser?.email ?? 'Email not found';

    Map<String, dynamic>? userProfile = await DatabaseService().getDataByEmail(
      email: userEmail,
      path: Words.profileData,
    );

    String _firstName = '';
    if (userProfile != null) {
      _firstName = userProfile[Words.profilefn];
    }
    return _firstName;
  }

  void sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatService.sendMessage(receiverId, message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _fetchName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              return Text('Chat window for ${snapshot.data}');
            }
          },
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppGradients.light),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Adjust the value as needed
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildUserInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getMessagesStream(receiverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        } else {
          final messages = snapshot.data!;
          return ListView.builder(
            reverse:
                true, // This is crucial for chat apps to show the newest messages at the bottom
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageItem(
                context,
                message,
              ); // <-- This is the corrected line
            },
          );
        }
      },
    );
  }

  // Assuming `currentUser` is a variable available in your widget's context or state
  // and holds the email/ID of the current user.
  // Assuming `currentUser` is a variable available in your widget's context or state.

  Widget _buildMessageItem(BuildContext context, Map<String, dynamic> message) {
    // Use a nullable type to handle the case where the key might not exist
    final String? sender = message['sender'] as String?;

    print(
      'Message data: $message',
    ); // Debugging line to inspect message structure
    print('sender: $sender'); // Debugging line to inspect sender value
    // Safely extract the text. This is the source of the crash.
    // We check if the value is a String before casting.
    final dynamic textValue = message['text'];
    final String? text = textValue is String ? textValue : null;

    // Check if the message is from the current user
    final bool isMe = sender == currentUser;

    // Align the message bubble to the right for the current user, left for othersq
    final AlignmentGeometry alignment = isMe
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          //color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey,
          color: isMe ? AppColors.primaryBlue : AppColors.accentGreen,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: isMe
                ? const Radius.circular(20.0)
                : const Radius.circular(0.0),
            bottomRight: isMe
                ? const Radius.circular(0.0)
                : const Radius.circular(20.0),
          ),
        ),
        child: Text(
          text ?? '', // Handle potential null text
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  /*
  Widget _buildMessageItem(BuildContext context, Map<String, dynamic> message) {
    // Use a nullable type to handle the case where the key might not exist
    final String? sender = message['sender'] as String?;
    final String? text =
        message as String?; // Fixed: Access the 'text' key from the map

    // Check if the message is from the current user
    final bool isMe = sender == currentUser;

    // Align the message bubble to the right for the current user, left for others
    final AlignmentGeometry alignment = isMe
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context)
                    .colorScheme
                    .primary // Fixed: Use colorScheme for primary color
              : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: isMe
                ? const Radius.circular(20.0)
                : const Radius.circular(0.0),
            bottomRight: isMe
                ? const Radius.circular(0.0)
                : const Radius.circular(20.0),
          ),
        ),
        child: Text(
          text ?? '', // Handle potential null text
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
*/
  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Type a message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  25.0,
                ), // Optional: rounded corners
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20.0,
              ),
            ),
          ),
        ),
        IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
      ],
    );
  }
}
