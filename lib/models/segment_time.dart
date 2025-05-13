// models/segment_time.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SegmentTime {
  final String id;
  final String participantId;
  final String raceId;
  final String segmentName;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String trackedBy;
  final DateTime createdAt;

  SegmentTime({
    required this.id,
    required this.participantId,
    required this.raceId,
    required this.segmentName,
    this.startTime,
    this.endTime,
    this.duration,
    required this.trackedBy,
    required this.createdAt,
  });

  bool get isCompleted => startTime != null && endTime != null;

  String get durationString {
    if (duration == null) return '--:--:--';

    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    final seconds = duration!.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant_id': participantId,
      'race_id': raceId,
      'segment_name': segmentName,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration': duration?.inMilliseconds,
      'tracked_by': trackedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SegmentTime.fromMap(Map<String, dynamic> map) {
    return SegmentTime(
      id: map['id'] ?? '',
      participantId: map['participant_id'] ?? '',
      raceId: map['race_id'] ?? '',
      segmentName: map['segment_name'] ?? '',
      startTime:
          map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      duration:
          map['duration'] != null
              ? Duration(milliseconds: map['duration'])
              : null,
      trackedBy: map['tracked_by'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  factory SegmentTime.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    data['id'] = snapshot.id;
    return SegmentTime.fromMap(data);
  }

  SegmentTime copyWith({
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
  }) {
    return SegmentTime(
      id: id,
      participantId: participantId,
      raceId: raceId,
      segmentName: segmentName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      trackedBy: trackedBy,
      createdAt: createdAt,
    );
  }
}
