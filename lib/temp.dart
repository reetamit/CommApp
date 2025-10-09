import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationFinderPage extends StatefulWidget {
  const LocationFinderPage({super.key});

  @override
  State<LocationFinderPage> createState() => _LocationFinderPageState();
}

class _LocationFinderPageState extends State<LocationFinderPage> {
  Position? _currentPosition;
  final double _searchRadiusInMiles = 30;
  List<Location> _nearbyLocations = [];

  // A list of hardcoded locations for demonstration.
  final List<Location> _allLocations = [
    Location(name: 'Park', latitude: 35.78, longitude: -78.63), // ~1 mile away
    Location(
      name: 'Museum',
      latitude: 35.79,
      longitude: -79.18,
    ), // ~30 miles away
    Location(
      name: 'Library',
      latitude: 35.95,
      longitude: -78.90,
    ), // ~25 miles away
    Location(
      name: 'Beach',
      latitude: 34.22,
      longitude: -77.94,
    ), // ~115 miles away
    Location(
      name: 'Mountains',
      latitude: 36.19,
      longitude: -81.67,
    ), // ~130 miles away
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Requests location permission and gets the current position.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return;
    }

    // Permissions granted, now get the current position.
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _findNearbyLocations();
    });
  }

  // Filters the list of all locations to find those within 30 miles.
  void _findNearbyLocations() {
    if (_currentPosition == null) return;

    List<Location> nearby = [];
    for (var location in _allLocations) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        location.latitude,
        location.longitude,
      );

      double distanceInMiles =
          distanceInMeters / 1609.34; // 1 mile = 1609.34 meters

      if (distanceInMiles <= _searchRadiusInMiles) {
        nearby.add(location);
      }
    }

    setState(() {
      _nearbyLocations = nearby;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Locations in 30 Miles')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentPosition != null)
              Text(
                'Current location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            const Text(
              'Locations within 30 miles:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_nearbyLocations.isEmpty)
              const Text('No locations found within 30 miles.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _nearbyLocations.length,
                  itemBuilder: (context, index) {
                    final loc = _nearbyLocations[index];
                    return ListTile(
                      title: Text(loc.name),
                      subtitle: Text(
                        'Lat: ${loc.latitude.toStringAsFixed(4)}, Long: ${loc.longitude.toStringAsFixed(4)}',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// A simple data model for a location.
class Location {
  final String name;
  final double latitude;
  final double longitude;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}
