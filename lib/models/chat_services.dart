import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/message.dart';
import 'package:rxdart/rxdart.dart';

class ChatService {
  // get instance of firestore

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final DatabaseReference _requestsRef = FirebaseDatabase.instance.ref().child(
    'Requests',
  );
  // Get the current user's email
  String currentUser =
      authServiceNotifier.value.currentUser?.email ?? 'Email not found';

  // Fetch requests where the current user is either the requester or the volunteer
  Stream<List<Map<String, dynamic>>> fetchUserRequestsStream() {
    // Stream 1: Requests where email matches
    final Stream<DatabaseEvent> emailStream = _requestsRef
        .orderByChild('email')
        .equalTo(currentUser)
        .onValue;

    // Stream 2: Requests where volunteerId matches
    final Stream<DatabaseEvent> volunteerIdStream = _requestsRef
        .orderByChild('volunteerId')
        .equalTo(currentUser)
        .onValue;

    // Combine the latest data from both streams
    return Rx.combineLatest2(emailStream, volunteerIdStream, (
      DatabaseEvent emailEvent,
      DatabaseEvent volunteerIdEvent,
    ) {
      final List<Map<String, dynamic>> allRequests = [];
      final Set<String> processedKeys = {};

      // Process the email results
      final Map<dynamic, dynamic>? emailResults =
          emailEvent.snapshot.value as Map?;
      if (emailResults != null) {
        emailResults.forEach((key, value) {
          if (value is Map) {
            allRequests.add(Map<String, dynamic>.from(value)..['key'] = key);
            processedKeys.add(key);
          }
        });
      }

      // Process the volunteerId results and add only unique requests
      final Map<dynamic, dynamic>? volunteerIdResults =
          volunteerIdEvent.snapshot.value as Map?;
      if (volunteerIdResults != null) {
        volunteerIdResults.forEach((key, value) {
          if (value is Map && !processedKeys.contains(key)) {
            allRequests.add(Map<String, dynamic>.from(value)..['key'] = key);
          }
        });
      }
      return allRequests;
    });
  }

  // send message to a request
  Future<void> sendMessage(String receiverUser, String message) async {
    Map<String, dynamic>? userProfile = await DatabaseService().getDataByEmail(
      email: currentUser,
      path: Words.profileData,
    );
    if (userProfile != null) {
      final String _firstName = userProfile[Words.profilefn];
      final String _lastName = userProfile[Words.profilelm];
    }

    Message newMessage = Message(
      sender: currentUser,
      text: message,
      receiver: receiverUser,
      timestamp: DateTime.now(),
    );

    List<String> ids = [currentUser, receiverUser];
    ids.sort(); // sort the ids to ensure consistent order
    String chatId = ids.join('_');

    //get messages of a request

    final DatabaseReference messagesRef = _firebaseDatabase
        .ref()
        .child('Messages')
        .push();
    await messagesRef.set(newMessage.toMap());
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(
    String currentUserEmail,
  ) {
    final DatabaseReference ref = _firebaseDatabase.ref().child('Messages');

    // Stream 1: Get messages where the current user is the sender
    final Stream<DatabaseEvent> sentMessagesStream = ref
        .orderByChild('sender')
        .equalTo(currentUserEmail)
        .onValue;

    // Stream 2: Get messages where the current user is the receiver
    final Stream<DatabaseEvent> receivedMessagesStream = ref
        .orderByChild('receiver')
        .equalTo(currentUserEmail)
        .onValue;

    // Combine the latest data from both streams
    return Rx.combineLatest2(sentMessagesStream, receivedMessagesStream, (
      DatabaseEvent sentEvent,
      DatabaseEvent receivedEvent,
    ) {
      final List<Map<String, dynamic>> allMessages = [];
      final Set<String> processedKeys = {};

      // Process the sent messages
      final Map<dynamic, dynamic>? sentMessagesData =
          sentEvent.snapshot.value as Map?;
      if (sentMessagesData != null) {
        sentMessagesData.forEach((key, value) {
          if (value is Map) {
            try {
              final message = Map<String, dynamic>.from(value);
              message['key'] = key;
              allMessages.add(message);
              processedKeys.add(key);
            } catch (e) {
              print('Error processing sent message: $e');
            }
          }
        });
      }

      // Process the received messages and add only unique ones
      final Map<dynamic, dynamic>? receivedMessagesData =
          receivedEvent.snapshot.value as Map?;
      if (receivedMessagesData != null) {
        receivedMessagesData.forEach((key, value) {
          if (value is Map && !processedKeys.contains(key)) {
            try {
              final message = Map<String, dynamic>.from(value);
              message['key'] = key;
              allMessages.add(message);
            } catch (e) {
              print('Error processing received message: $e');
            }
          }
        });
      }

      // Sort all messages by timestamp
      allMessages.sort((a, b) {
        final aTimestamp = DateTime.parse(a['timestamp']);
        final bTimestamp = DateTime.parse(b['timestamp']);
        return aTimestamp.compareTo(bTimestamp);
      });

      return allMessages;
    });
  }
  /*
  Stream<List<Map<String, dynamic>>> getMessagesStream(String receiverUser) {
    List<String> ids = [currentUser, receiverUser];
    ids.sort(); // Sort the user IDs to ensure a consistent chat ID
    String chatId = ids.join('_');

    final DatabaseReference chatRef = _firebaseDatabase
        .ref()
        .child('Messages')
        .child(chatId); // Access the specific chat room

    // The query should order by the timestamp for chronological sorting
    Query query = chatRef.orderByChild('timestamp');

    return query.onValue.map((event) {
      final data = event.snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        // Create a list of messages from the map
        final messages = data.entries
            .map((entry) {
              final messageData = entry.value;

              // Use a try-catch block to handle potential casting errors gracefully
              try {
                if (messageData is Map<dynamic, dynamic>) {
                  final int timestampInMillis =
                      messageData['timestamp'] as int? ?? 0;
                  final DateTime timestamp =
                      DateTime.fromMillisecondsSinceEpoch(timestampInMillis);

                  return {
                    'sender': messageData['sender'] as String? ?? '',
                    'text': messageData['text'] as String? ?? '',
                    'receiver': messageData['receiver'] as String? ?? '',
                    'timestamp': timestamp.toIso8601String(),
                  };
                } else {
                  print('Skipping malformed message entry: ${entry.value}');
                  return null; // Return null for invalid messages
                }
              } catch (e) {
                print(
                  'Error processing message entry: ${entry.value}. Error: $e',
                );
                return null; // Return null if an error occurs
              }
            })
            .whereType<Map<String, dynamic>>()
            .toList(); // Filter out any null entries

        return messages;
      } else {
        // Handle cases where snapshot value is not a map (e.g., if it's null or not in the expected format)
        print(
          'Snapshot value is not a map or is null: ${event.snapshot.value}',
        );
        return [];
      }
    });
  }
*/
}
