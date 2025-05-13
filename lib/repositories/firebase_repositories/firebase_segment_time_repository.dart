// repositories/firebase_repositories/firebase_segment_time_repository.dart - No Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import '../abstract_repositories/segment_time_repository.dart';
import '../../models/segment_time.dart';
import '../../services/firebase_service.dart';

class FirebaseSegmentTimeRepository implements SegmentTimeRepository {
  final CollectionReference _segmentTimesCollection =
      FirebaseService.segmentTimes;

  @override
  Future<List<SegmentTime>> getSegmentTimesByParticipantId(
    String participantId,
  ) async {
    try {
      final snapshot =
          await _segmentTimesCollection
              .where('participant_id', isEqualTo: participantId)
              .get();
      return snapshot.docs
          .map(
            (doc) => SegmentTime.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get segment times for participant: $e');
    }
  }

  @override
  Future<List<SegmentTime>> getSegmentTimesByRaceId(String raceId) async {
    try {
      final snapshot =
          await _segmentTimesCollection
              .where('race_id', isEqualTo: raceId)
              .get();
      return snapshot.docs
          .map(
            (doc) => SegmentTime.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get segment times for race: $e');
    }
  }

  @override
  Future<SegmentTime?> getSegmentTime(
    String participantId,
    String segmentName,
  ) async {
    try {
      final snapshot =
          await _segmentTimesCollection
              .where('participant_id', isEqualTo: participantId)
              .where('segment_name', isEqualTo: segmentName)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return SegmentTime.fromFirestore(
          snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get segment time: $e');
    }
  }

  @override
  Future<String> createSegmentTime(SegmentTime segmentTime) async {
    try {
      final docRef = await _segmentTimesCollection.add(segmentTime.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create segment time: $e');
    }
  }

  @override
  Future<void> updateSegmentTime(SegmentTime segmentTime) async {
    try {
      await _segmentTimesCollection
          .doc(segmentTime.id)
          .update(segmentTime.toMap());
    } catch (e) {
      throw Exception('Failed to update segment time: $e');
    }
  }

  @override
  Future<void> deleteSegmentTime(String id) async {
    try {
      await _segmentTimesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete segment time: $e');
    }
  }

  @override
  Future<void> trackTime(
    String participantId,
    String raceId,
    String segmentName,
  ) async {
    try {
      // Check if segment time already exists
      final existingSegmentTime = await getSegmentTime(
        participantId,
        segmentName,
      );

      if (existingSegmentTime != null) {
        // Update end time if only start time exists
        if (existingSegmentTime.startTime != null &&
            existingSegmentTime.endTime == null) {
          final endTime = DateTime.now();
          final duration = endTime.difference(existingSegmentTime.startTime!);

          await updateSegmentTime(
            existingSegmentTime.copyWith(endTime: endTime, duration: duration),
          );
        }
      } else {
        // Create new segment time with start time
        final segmentTime = SegmentTime(
          id: '',
          participantId: participantId,
          raceId: raceId,
          segmentName: segmentName,
          startTime: DateTime.now(),
          trackedBy: 'system', // No auth, use system
          createdAt: DateTime.now(),
        );

        await createSegmentTime(segmentTime);
      }
    } catch (e) {
      throw Exception('Failed to track time: $e');
    }
  }

  @override
  Future<void> untrackTime(String participantId, String segmentName) async {
    try {
      final segmentTime = await getSegmentTime(participantId, segmentName);
      if (segmentTime != null) {
        await deleteSegmentTime(segmentTime.id);
      }
    } catch (e) {
      throw Exception('Failed to untrack time: $e');
    }
  }

  @override
  Stream<List<SegmentTime>> watchSegmentTimesByRaceId(String raceId) {
    return _segmentTimesCollection
        .where('race_id', isEqualTo: raceId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => SegmentTime.fromFirestore(
                      doc as DocumentSnapshot<Map<String, dynamic>>,
                    ),
                  )
                  .toList(),
        );
  }
}
