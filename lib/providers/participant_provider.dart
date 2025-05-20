import 'package:flutter/material.dart';
import 'dart:async';
import '../models/participant.dart';
import '../repositories/firebase_repositories/firebase_participant_repository.dart';

class ParticipantProvider with ChangeNotifier {
  final FirebaseParticipantRepository _participantRepository =
      FirebaseParticipantRepository();
  List<Participant> _participants = [];
  Participant? _selectedParticipant;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Participant>>? _participantsSubscription;

  List<Participant> get participants => _participants;
  Participant? get selectedParticipant => _selectedParticipant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _participantsSubscription?.cancel();
    super.dispose();
  }

  void watchParticipantsByRaceId(String raceId) {
    _participantsSubscription?.cancel();
    _participantsSubscription = _participantRepository
        .watchParticipantsByRaceId(raceId)
        .listen(
          (participants) {
            _participants = participants;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> getParticipantsByRaceId(String raceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _participants = await _participantRepository.getParticipantsByRaceId(
        raceId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createParticipant({
    required String bibNumber,
    required String firstName,
    required String lastName,
    required int age,
    required Gender gender,
    required String raceId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if BIB number already exists for this race
      final existingParticipant = await _participantRepository
          .getParticipantByBibNumber(bibNumber, raceId);
      if (existingParticipant != null) {
        _error = 'BIB number $bibNumber already exists for this race';
        return null;
      }

      final participant = Participant(
        id: '',
        bibNumber: bibNumber,
        firstName: firstName,
        lastName: lastName,
        age: age,
        gender: gender,
        raceId: raceId,
        createdAt: DateTime.now(),
      );

      final participantId = await _participantRepository.createParticipant(
        participant,
      );
      _error = null;
      return participantId;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateParticipant(Participant participant) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _participantRepository.updateParticipant(participant);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteParticipant(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _participantRepository.deleteParticipant(id);
      _participants.removeWhere((participant) => participant.id == id);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startAllParticipants(String raceId) async {
    try {
      final currentTime = DateTime.now();

      // Get all participants for this race
      final raceParticipants =
          _participants.where((p) => p.raceId == raceId).toList();

      // Start all participants simultaneously
      for (final participant in raceParticipants) {
        await _participantRepository.startParticipant(
          participant.id,
          currentTime,
        );
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Participant?> getParticipantByBibNumber(
    String bibNumber,
    String raceId,
  ) async {
    try {
      return await _participantRepository.getParticipantByBibNumber(
        bibNumber,
        raceId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void selectParticipant(Participant participant) {
    _selectedParticipant = participant;
    notifyListeners();
  }

  void clearSelection() {
    _selectedParticipant = null;
    notifyListeners();
  }

  void clearParticipants() {
    _participants.clear();
    _participantsSubscription?.cancel();
    notifyListeners();
  }
}
