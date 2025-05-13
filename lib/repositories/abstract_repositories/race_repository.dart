// repositories/abstract_repositories/race_repository.dart
import '../../models/race.dart';

abstract class RaceRepository {
  Future<List<Race>> getAllRaces();
  Future<Race?> getRaceById(String id);
  Future<String> createRace(Race race);
  Future<void> updateRace(Race race);
  Future<void> deleteRace(String id);
  Future<void> startRace(String id);
  Future<void> finishRace(String id);
  Future<void> resetRace(String id);
  Stream<List<Race>> watchAllRaces();
  Stream<Race?> watchRaceById(String id);
}
