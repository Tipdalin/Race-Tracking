// repositories/firebase_repositories/firebase_participant_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../abstract_repositories/participant_repository.dart';
import '../../models/participant.dart';
import '../../services/firebase_service.dart';

class FirebaseParticipantRepository implements ParticipantRepository {
  final CollectionReference _participantsCollection =
      FirebaseService.participants;

  @override
  Future<List<Participant>> getAllParticipants() async {
    try {
      final snapshot = await _participantsCollection.get();
      return snapshot.docs
          .map(
            (doc) => Participant.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get participants: $e');
    }
  }

  @override
  Future<List<Participant>> getParticipantsByRaceId(String raceId) async {
    try {
      final snapshot =
          await _participantsCollection
              .where('race_id', isEqualTo: raceId)
              .get();
      return snapshot.docs
          .map(
            (doc) => Participant.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get participants for race: $e');
    }
  }

  @override
  Future<Participant?> getParticipantById(String id) async {
    try {
      final doc = await _participantsCollection.doc(id).get();
      if (doc.exists) {
        return Participant.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get participant: $e');
    }
  }

  @override
  Future<Participant?> getParticipantByBibNumber(
    String bibNumber,
    String raceId,
  ) async {
    try {
      final snapshot =
          await _participantsCollection
              .where('bib_number', isEqualTo: bibNumber)
              .where('race_id', isEqualTo: raceId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return Participant.fromFirestore(
          snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get participant by BIB number: $e');
    }
  }

  @override
  Future<String> createParticipant(Participant participant) async {
    try {
      final docRef = await _participantsCollection.add(participant.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create participant: $e');
    }
  }

  @override
  Future<void> updateParticipant(Participant participant) async {
    try {
      await _participantsCollection
          .doc(participant.id)
          .update(participant.toMap());
    } catch (e) {
      throw Exception('Failed to update participant: $e');
    }
  }

  @override
  Future<void> deleteParticipant(String id) async {
    try {
      await _participantsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete participant: $e');
    }
  }

  @override
  Stream<List<Participant>> watchParticipantsByRaceId(String raceId) {
    return _participantsCollection
        .where('race_id', isEqualTo: raceId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Participant.fromFirestore(
                      doc as DocumentSnapshot<Map<String, dynamic>>,
                    ),
                  )
                  .toList(),
        );
  }
}
