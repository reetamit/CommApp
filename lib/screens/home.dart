import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../models/request.dart';
import 'request_response.dart';
import 'package:flutter_app/models/utility.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

//class HomePage extends StatefulWidget {
//  HomePage({super.key});
class _HomeScreenState extends State<HomeScreen> {
  List<Request> requests = [];
  List<Request> filteredRequests = [];
  List<Location> locations = [];

  double _latitude = 0.0;
  double _longitude = 0.0;

  Future<void> _fetchCurrentUsrLoc(String userEmail) async {
    Map<String, dynamic>? userProfile = await DatabaseService().getDataByEmail(
      email: userEmail,
      path: Words.profileData,
    );

    if (userProfile != null) {
      _latitude = userProfile[Words.profilelt] ?? 0.0;
      _longitude = userProfile[Words.profilelg] ?? 0.0;
    } else {
      _latitude = 0.0;
      _longitude = 0.0;
    }
  }

  Future<String> _fetchName(String userEmail) async {
    Map<String, dynamic>? userProfile = await DatabaseService().getDataByEmail(
      email: userEmail,
      path: Words.profileData,
    );

    if (userProfile != null) {
      _latitude = userProfile[Words.profilelt] ?? 0.0;
      _longitude = userProfile[Words.profilelg] ?? 0.0;
      String firstName = userProfile[Words.profilefn] ?? 'Name unknown';
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
    await _fetchCurrentUsrLoc(userEmail);

    List<String> nearby = [];

    // Retrieve requests from the database to get the list of requests
    DataSnapshot? snapshot = await DatabaseService().read(
      path: Words.requestData,
    );

    // Retrieve requests from the database to get the list of requests
    DataSnapshot? profilesnapshot = await DatabaseService().read(
      path: Words.profileData,
    );

    if (snapshot != null) {
      final Map<dynamic, dynamic> values =
          snapshot.value as Map<dynamic, dynamic>;

      if (profilesnapshot != null) {
        final Map<dynamic, dynamic> pvalues =
            profilesnapshot.value as Map<dynamic, dynamic>;

        // To store keys in a list
        /*List<dynamic> keysList = values.keys.toList();
      //List<Object>? mylist = values.values.cast<Object>().toList();
      requests = mylist
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (data) => Request(
              title: data[Words.requestType] ?? 'No Title',
              description: data[Words.requestDesc] ?? 'No Description',
              email: data[Words.requestUser] ?? 'No Email',
              status: data[Words.requestStatus] ?? 'No Status',
              firstName: _fetchName(
                data[Words.requestUser] ?? 'No Email',
              ).toString(),
              dateTime:
                  DateTime.tryParse(data[Words.requestTimestamp] ?? '') ??
                  DateTime.now(),
            ),
          )
          .toList();
    }*/

        locations = pvalues.entries
            // Filter out entries whose values aren't the expected map type.
            .where((entry) => entry.value is Map<dynamic, dynamic>)
            .map((entry) {
              // Here, 'entry.key' gives you the key and 'entry.value' gives you the value.
              final Map<dynamic, dynamic> data =
                  entry.value as Map<dynamic, dynamic>;

              return Location(
                // Example of using the value
                email: data[Words.profilemail] ?? 'No Name',
                latitude: data[Words.profilelt] ?? 0.0,
                longitude: data[Words.profilelg] ?? 0.0,
              );
            })
            .toList();

        for (var loc in locations) {
          double distanceInMeters = Geolocator.distanceBetween(
            _latitude,
            _longitude,
            loc.latitude,
            loc.longitude,
          );

          double distanceInMiles =
              distanceInMeters / 1609.34; // 1 mile = 1609.34 meters

          print(
            'Location: ${loc.email}, Distance: ${distanceInMiles.toStringAsFixed(2)} miles',
          );
          if (distanceInMiles <= Words.searchRadiusInMiles) {
            nearby.add(loc.email);
          }
        }
      }
      requests = values.entries
          // Filter out entries whose values aren't the expected map type.
          .where((entry) => entry.value is Map<dynamic, dynamic>)
          .map((entry) {
            // Here, 'entry.key' gives you the key and 'entry.value' gives you the value.
            final dynamic key = entry.key;
            final Map<dynamic, dynamic> data =
                entry.value as Map<dynamic, dynamic>;

            return Request(
              // Example of using the value
              title: data[Words.requestType] ?? 'No Title',
              description: data[Words.requestDesc] ?? 'No Description',
              email: data[Words.requestUser] ?? 'No Email',
              status: data[Words.requestStatus] ?? 'No Status',
              key: key.toString(),
              dateTime:
                  DateTime.tryParse(data[Words.requestTimestamp] ?? '') ??
                  DateTime.now(),
              // You can also use the key here if needed, for example:
              // requestId: key,
            );
          })
          .toList();
    }

    filteredRequests = [];
    for (var req in requests) {
      if (nearby.contains(req.email) &&
          req.status.toLowerCase() != 'completed') {
        filteredRequests.add(req);
      }
    }

    print("Filted: ${filteredRequests.length}");
    print("UnFilted: ${requests.length}");
    print("NearBy: ${nearby.length}");

    filteredRequests.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    setState(() {}); // Refresh UI with fetched data
  }

  // Helper function to get the color based on the status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue[100]!; // Using a lighter shade of blue
      case 'responded':
        return Colors.amber[100]!; // Using a lighter shade of amber
      case 'completed':
        return Colors.green[100]!; // Using a lighter shade of green
      default:
        return Colors.grey[100]!; // Default color for unknown status
    }
  }

  // This function is called only once.
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    if (filteredRequests.isEmpty) {
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
          itemCount: filteredRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final req = filteredRequests[index];
            return InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => RequestResponseScreen(request: req),
                      ),
                    )
                    .then((value) => _fetchRequests());
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: _getStatusColor(req.status),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                  //color: Colors.grey[100],
                  //borderRadius: BorderRadius.circular(8.0),
                  //border: Border.all(color: Colors.grey.shade300),
                ),
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
