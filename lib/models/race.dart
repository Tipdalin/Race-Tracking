// models/race.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum RaceStatus { notStarted, inProgress, finished }

class Segment {
  final String name;
  final String distance;
  final int order;

  Segment({required this.name, required this.distance, required this.order});

  Map<String, dynamic> toMap() {
    return {'name': name, 'distance': distance, 'order': order};
  }

  factory Segment.fromMap(Map<String, dynamic> map) {
    return Segment(
      name: map['name'] ?? '',
      distance: map['distance'] ?? '',
      order: map['order'] ?? 0,
    );
  }
}

class Race {
  final String id;
  final String name;
  final String type;
  final RaceStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<Segment> segments;
  final String createdBy;
  final DateTime createdAt;

  Race({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.startTime,
    this.endTime,
    required this.segments,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status.toString(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'segments': segments.map((s) => s.toMap()).toList(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Race.fromMap(Map<String, dynamic> map) {
    return Race(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      status: RaceStatus.values.firstWhere(
        (status) => status.toString() == map['status'],
        orElse: () => RaceStatus.notStarted,
      ),
      startTime:
          map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      segments:
          (map['segments'] as List<dynamic>?)
              ?.map((s) => Segment.fromMap(s))
              .toList() ??
          [],
      createdBy: map['created_by'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  factory Race.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    data['id'] = snapshot.id;
    return Race.fromMap(data);
  }

  Race copyWith({
    String? name,
    String? type,
    RaceStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    List<Segment>? segments,
  }) {
    return Race(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      segments: segments ?? this.segments,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  String get statusString {
    switch (status) {
      case RaceStatus.notStarted:
        return 'Not Started';
      case RaceStatus.inProgress:
        return 'In Progress';
      case RaceStatus.finished:
        return 'Finished';
    }
  }
}
