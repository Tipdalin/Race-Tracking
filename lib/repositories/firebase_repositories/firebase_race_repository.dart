import 'package:cloud_firestore/cloud_firestore.dart';
import '../abstract_repositories/race_repository.dart';
import '../../models/race.dart';
import '../../services/firebase_service.dart';

class FirebaseRaceRepository implements RaceRepository {
  final CollectionReference _racesCollection = FirebaseService.races;

  @override
  Future<List<Race>> getAllRaces() async {
    try {
      final snapshot = await _racesCollection.get();
      return snapshot.docs
          .map(
            (doc) => Race.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get races: $e');
    }
  }

  @override
  Future<Race?> getRaceById(String id) async {
    try {
      final doc = await _racesCollection.doc(id).get();
      if (doc.exists) {
        return Race.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get race: $e');
    }
  }

  @override
  Future<String> createRace(Race race) async {
    try {
      final docRef = await _racesCollection.add(race.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create race: $e');
    }
  }

  @override
  Future<void> updateRace(Race race) async {
    try {
      await _racesCollection.doc(race.id).update(race.toMap());
    } catch (e) {
      throw Exception('Failed to update race: $e');
    }
  }

  @override
  Future<void> deleteRace(String id) async {
    try {
      await _racesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete race: $e');
    }
  }

  @override
  Future<void> startRace(String id) async {
    try {
      await _racesCollection.doc(id).update({
        'status': RaceStatus.inProgress.toString(),
        'start_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to start race: $e');
    }
  }

  @override
  Future<void> finishRace(String id) async {
    try {
      await _racesCollection.doc(id).update({
        'status': RaceStatus.finished.toString(),
        'end_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to finish race: $e');
    }
  }

  @override
  Future<void> resetRace(String id) async {
    try {
      // Reset race status and clear times
      await _racesCollection.doc(id).update({
        'status': RaceStatus.notStarted.toString(),
        'start_time': null,
        'end_time': null,
      });

      // Delete all segment times for this race
      final segmentTimes =
          await FirebaseService.segmentTimes
              .where('race_id', isEqualTo: id)
              .get();

      for (var doc in segmentTimes.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to reset race: $e');
    }
  }

  @override
  Stream<List<Race>> watchAllRaces() {
    return _racesCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => Race.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
    );
  }

  @override
  Stream<Race?> watchRaceById(String id) {
    return _racesCollection
        .doc(id)
        .snapshots()
        .map(
          (doc) =>
              doc.exists
                  ? Race.fromFirestore(
                    doc as DocumentSnapshot<Map<String, dynamic>>,
                  )
                  : null,
        );
  }
}
