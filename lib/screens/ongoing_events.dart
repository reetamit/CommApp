import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/event.dart';
import 'package:flutter_app/models/utility.dart';
import 'package:flutter_app/screens/event_edit.dart';

// Dummy screens for the tabs
class OngoingEventsScreen extends StatefulWidget {
  //const OngoingEventsScreen({super.key});
  @override
  _OngoingEventsScreenState createState() => _OngoingEventsScreenState();
}

class _OngoingEventsScreenState extends State<OngoingEventsScreen> {
  List<Event> events = [];
  List<Event> filteredEvents = [];

  Future<String> _fetchName(String userEmail) async {
    Map<String, dynamic>? eventUsrData = await DatabaseService().getDataByEmail(
      email: userEmail,
      path: Words.eventPath,
    );

    if (eventUsrData != null) {
      String firstName = eventUsrData[Words.eventUser] ?? 'Name unknown';
      print(firstName);
      return firstName.toString();
    } else {
      return 'Name unknown';
    }
  }

  Future<void> _fetchRequests() async {
    // Get the current user's email
    final userEmail =
        authServiceNotifier.value.currentUser?.email ?? 'Email not found';
    //await _fetchCurrentUsrLoc(userEmail);

    //List<String> nearby = [];

    // Retrieve requests from the database to get the list of requests
    DataSnapshot? snapshot = await DatabaseService().read(
      path: Words.eventPath,
    );

    if (snapshot != null) {
      final Map<dynamic, dynamic> values =
          snapshot.value as Map<dynamic, dynamic>;

      events = values.entries
          // Filter out entries whose values aren't the expected map type.
          .where((entry) => entry.value is Map<dynamic, dynamic>)
          .map((entry) {
            // Here, 'entry.key' gives you the key and 'entry.value' gives you the value.
            final dynamic key = entry.key;
            final Map<dynamic, dynamic> data =
                entry.value as Map<dynamic, dynamic>;

            return Event(
              // Example of using the value
              title: data[Words.eventType] ?? 'No Title',
              description: data[Words.eventDesc] ?? 'No Description',
              email: data[Words.eventUser] ?? 'No Email',
              status: data[Words.eventStatus] ?? 'No Status',
              key: key.toString(),
              dateTime:
                  DateTime.tryParse(data[Words.eventTimestamp] ?? '') ??
                  DateTime.now(),
              // You can also use the key here if needed, for example:
              // requestId: key,
            );
          })
          .toList();
    }

    filteredEvents = [];
    for (var req in events) {
      if (req.status.toLowerCase() != 'completed') {
        filteredEvents.add(req);
      }
    }
    filteredEvents.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    setState(() {}); // Refresh UI with fetched data
  }

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    if (filteredEvents.isEmpty) {
      return const Center(
        child: Text('There is no request pending from your community!'),
      );
    } else {
      return Scaffold(
        // appBar: AppBar(title: const Text('Requests')),
        /*appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          // Apply a Container with the gradient here
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.accentGreen, AppColors.primaryBlue],
            ),
          ),
        ),
      ),*/
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
          itemCount: filteredEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final req = filteredEvents[index];
            return InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => EventEditScreen(event: req),
                      ),
                    )
                    .then((value) => _fetchRequests());
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),

                child: Row(
                  children: [
                    // --- Add the Icon widget here ---
                    Icon(
                      Icons.message_outlined, // Use an appropriate icon
                      color: Colors.grey[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12), // Add some spacing
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Use FutureBuilder to display the name
                          FutureBuilder<String>(
                            future: _fetchName(req.email),
                            builder: (context, snapshot) {
                              // Display a loading indicator or placeholder text
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  'Request from: ${req.email.split('@')[0]} (Loading...)',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }
                              // Display the fetched name
                              else if (snapshot.hasData) {
                                return Text(
                                  'Request from: ${snapshot.data}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }
                              // Display an error or default message
                              else {
                                return Text(
                                  'Request from: ${req.email.split('@')[0]} (Name unknown)',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                          Text(
                            req.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utility.formatDateTime(req.dateTime),
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Status: ${req.status}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Add the FloatingActionButton here
        floatingActionButton: FloatingActionButton(
          onPressed: _fetchRequests, // Call the function that fetches the data
          child: const Icon(Icons.refresh),
        ),
      );
    }
  }
}
