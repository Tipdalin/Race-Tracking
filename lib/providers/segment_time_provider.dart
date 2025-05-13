// providers/segment_time_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/segment_time.dart';
import '../repositories/firebase_repositories/firebase_segment_time_repository.dart';

class SegmentTimeProvider with ChangeNotifier {
  final FirebaseSegmentTimeRepository _segmentTimeRepository =
      FirebaseSegmentTimeRepository();
  List<SegmentTime> _segmentTimes = [];
  Map<String, List<SegmentTime>> _participantSegmentTimes = {};
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<SegmentTime>>? _segmentTimesSubscription;

  List<SegmentTime> get segmentTimes => _segmentTimes;
  Map<String, List<SegmentTime>> get participantSegmentTimes =>
      _participantSegmentTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _segmentTimesSubscription?.cancel();
    super.dispose();
  }

  void watchSegmentTimesByRaceId(String raceId) {
    _segmentTimesSubscription?.cancel();
    _segmentTimesSubscription = _segmentTimeRepository
        .watchSegmentTimesByRaceId(raceId)
        .listen(
          (segmentTimes) {
            _segmentTimes = segmentTimes;
            _organizeSegmentTimesByParticipant();
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  void _organizeSegmentTimesByParticipant() {
    _participantSegmentTimes.clear();
    for (final segmentTime in _segmentTimes) {
      if (_participantSegmentTimes[segmentTime.participantId] == null) {
        _participantSegmentTimes[segmentTime.participantId] = [];
      }
      _participantSegmentTimes[segmentTime.participantId]!.add(segmentTime);
    }
  }

  Future<bool> trackTime(
    String participantId,
    String raceId,
    String segmentName,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _segmentTimeRepository.trackTime(
        participantId,
        raceId,
        segmentName,
      );
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

  Future<bool> untrackTime(String participantId, String segmentName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _segmentTimeRepository.untrackTime(participantId, segmentName);
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

  Future<void> getSegmentTimesByRaceId(String raceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _segmentTimes = await _segmentTimeRepository.getSegmentTimesByRaceId(
        raceId,
      );
      _organizeSegmentTimesByParticipant();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<SegmentTime> getParticipantSegmentTimes(String participantId) {
    return _participantSegmentTimes[participantId] ?? [];
  }

  SegmentTime? getParticipantSegmentTime(
    String participantId,
    String segmentName,
  ) {
    final participantTimes = _participantSegmentTimes[participantId] ?? [];
    for (final time in participantTimes) {
      if (time.segmentName == segmentName) {
        return time;
      }
    }
    return null;
  }

  Duration? getParticipantTotalTime(String participantId) {
    final participantTimes = _participantSegmentTimes[participantId] ?? [];
    if (participantTimes.isEmpty) return null;

    Duration total = Duration.zero;
    bool allComplete = true;

    for (final time in participantTimes) {
      if (time.duration != null) {
        total += time.duration!;
      } else {
        allComplete = false;
      }
    }

    return allComplete ? total : null;
  }

  void clearSegmentTimes() {
    _segmentTimes.clear();
    _participantSegmentTimes.clear();
    _segmentTimesSubscription?.cancel();
    notifyListeners();
  }
}
