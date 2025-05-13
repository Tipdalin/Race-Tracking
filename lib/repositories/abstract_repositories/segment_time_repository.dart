// repositories/abstract_repositories/segment_time_repository.dart
import '../../models/segment_time.dart';

abstract class SegmentTimeRepository {
  Future<List<SegmentTime>> getSegmentTimesByParticipantId(
    String participantId,
  );
  Future<List<SegmentTime>> getSegmentTimesByRaceId(String raceId);
  Future<SegmentTime?> getSegmentTime(String participantId, String segmentName);
  Future<String> createSegmentTime(SegmentTime segmentTime);
  Future<void> updateSegmentTime(SegmentTime segmentTime);
  Future<void> deleteSegmentTime(String id);
  Future<void> trackTime(
    String participantId,
    String raceId,
    String segmentName,
  );
  Future<void> untrackTime(String participantId, String segmentName);
  Stream<List<SegmentTime>> watchSegmentTimesByRaceId(String raceId);
}
