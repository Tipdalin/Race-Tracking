import '../../models/participant.dart';

abstract class ParticipantRepository {
  Future<List<Participant>> getAllParticipants();
  Future<List<Participant>> getParticipantsByRaceId(String raceId);
  Future<Participant?> getParticipantById(String id);
  Future<Participant?> getParticipantByBibNumber(
    String bibNumber,
    String raceId,
  );
  Future<String> createParticipant(Participant participant);
  Future<void> updateParticipant(Participant participant);
  Future<void> deleteParticipant(String id);
  Stream<List<Participant>> watchParticipantsByRaceId(String raceId);
}
