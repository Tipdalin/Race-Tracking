import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;

  static FirebaseFirestore get firestore =>
      _firestore ??= FirebaseFirestore.instance;

  static Future<void> initialize() async {
    // Enable offline persistence
    firestore.settings = const Settings(persistenceEnabled: true);
  }

  // Collections
  static CollectionReference get races => firestore.collection('races');
  static CollectionReference get participants =>
      firestore.collection('participants');
  static CollectionReference get segmentTimes =>
      firestore.collection('segment_times');

  // Generate a unique ID for operations that need it
  static String generateId() {
    return firestore.collection('dummy').doc().id;
  }
}
