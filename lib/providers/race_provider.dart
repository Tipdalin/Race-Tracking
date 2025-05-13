// providers/race_provider.dart - Simplified without authentication
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/race.dart';
import '../repositories/firebase_repositories/firebase_race_repository.dart';

class RaceProvider with ChangeNotifier {
  final FirebaseRaceRepository _raceRepository = FirebaseRaceRepository();
  List<Race> _races = [];
  Race? _selectedRace;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Race>>? _racesSubscription;
  StreamSubscription<Race?>? _selectedRaceSubscription;

  List<Race> get races => _races;
  Race? get selectedRace => _selectedRace;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _racesSubscription?.cancel();
    _selectedRaceSubscription?.cancel();
    super.dispose();
  }

  void watchAllRaces() {
    _racesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _racesSubscription = _raceRepository.watchAllRaces().listen(
      (races) {
        _races = races;
        _error = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error watching races: $error');
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void watchSelectedRace(String raceId) {
    _selectedRaceSubscription?.cancel();
    _selectedRaceSubscription = _raceRepository
        .watchRaceById(raceId)
        .listen(
          (race) {
            _selectedRace = race;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            print('Error watching selected race: $error');
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> getAllRaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _races = await _raceRepository.getAllRaces();
      _error = null;
    } catch (e) {
      print('Error getting all races: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createRace(
    String name,
    String type,
    List<Segment> segments,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final race = Race(
        id: '',
        name: name,
        type: type,
        status: RaceStatus.notStarted,
        segments: segments,
        createdBy: 'anonymous', // No auth, use anonymous
        createdAt: DateTime.now(),
      );

      final raceId = await _raceRepository.createRace(race);
      _error = null;
      return raceId;
    } catch (e) {
      print('Error creating race: $e');
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRace(Race race) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepository.updateRace(race);
      _error = null;
      return true;
    } catch (e) {
      print('Error updating race: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRace(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepository.deleteRace(id);
      _races.removeWhere((race) => race.id == id);
      _error = null;
      return true;
    } catch (e) {
      print('Error deleting race: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startRace(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepository.startRace(id);
      _error = null;
      return true;
    } catch (e) {
      print('Error starting race: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> finishRace(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepository.finishRace(id);
      _error = null;
      return true;
    } catch (e) {
      print('Error finishing race: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetRace(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepository.resetRace(id);
      _error = null;
      return true;
    } catch (e) {
      print('Error resetting race: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRace(Race race) {
    _selectedRace = race;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRace = null;
    _selectedRaceSubscription?.cancel();
    notifyListeners();
  }

  // Method to refresh data
  Future<void> refresh() async {
    _error = null;
    notifyListeners();

    // Re-initialize streams
    watchAllRaces();
    if (_selectedRace != null) {
      watchSelectedRace(_selectedRace!.id);
    }
  }
}
