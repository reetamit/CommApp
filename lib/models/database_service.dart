import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/localization/words.dart';

class DatabaseService {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  //Create (update)
  Future<void> create({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    //String jsonData = jsonEncode(data);
    //final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    //await ref.set(data);
    // 1. Get a reference to the path.
    final DatabaseReference parentRef = _firebaseDatabase.ref().child(path);
    // 2. Call push() on the parent reference to get a new unique key.
    final DatabaseReference newChildRef = parentRef.push();
    // 3. Set the data on the new child reference.
    await newChildRef.set(data);
  }

  // Read
  Future<DataSnapshot?> read({required String path}) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    final DataSnapshot snapshot = await ref.get();
    return snapshot.exists ? snapshot : null;
  }

  // Update
  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.update(data);
  }

  // Delete
  Future<void> delete({required String path}) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.remove();
  }

  Future<Map<String, dynamic>?> getDataByEmail({
    required String email,
    required String path,
  }) async {
    try {
      final DatabaseReference ref = _firebaseDatabase.ref().child(path);
      // Query the 'Profile' path for a child whose 'email' field matches the provided email.
      Query query = ref.orderByChild(Words.profilemail).equalTo(email);
      DatabaseEvent event = await query.once();

      if (event.snapshot.value != null) {
        // The snapshot value will be a Map<String, dynamic> where keys are user IDs
        // and values are the path data.
        Map<dynamic, dynamic> pathData =
            event.snapshot.value as Map<dynamic, dynamic>;

        // Assuming email is unique, there should be only one matching profile.
        // Iterate through the profiles to find the one with the matching email.
        for (var entry in pathData.entries) {
          if (entry.value is Map<dynamic, dynamic>) {
            Map<String, dynamic> dataList = Map<String, dynamic>.from(
              entry.value,
            );
            if (dataList['email'] == email) {
              return dataList;
            }
          }
        }
      }
      return null; // No profile found for the given email
    } catch (e) {
      print("Error retrieving profile: $e");
      return null;
    }
  }

  // Assume 'snapshot' is the DataSnapshot of the parent "Requests" node
  Future<String> getRequestIds({
    required String email,
    required String path,
  }) async {
    try {
      final DatabaseReference ref = _firebaseDatabase.ref().child(path);
      // Query the 'Profile' path for a child whose 'email' field matches the provided email.
      Query query = ref.orderByChild(Words.profilemail).equalTo(email);
      DatabaseEvent event = await query.once();

      if (event.snapshot.value != null && event.snapshot.value is Map) {
        Map<dynamic, dynamic> requestsMap = event.snapshot.value as Map;
        requestsMap.keys.forEach((key) {
          print('Request ID: $key'); // This will print each request ID
          return key;
        });
      }
      return 'Key not found'; // No profile found for the given email
    } catch (e) {
      print("Error retrieving profile: $e");
      return e.toString();
    }
  }
}
