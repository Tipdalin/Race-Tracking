// models/participant.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }

class Participant {
  final String id;
  final String bibNumber;
  final String firstName;
  final String lastName;
  final int age;
  final Gender gender;
  final String raceId;
  final DateTime createdAt;

  Participant({
    required this.id,
    required this.bibNumber,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.raceId,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  String get genderString {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bib_number': bibNumber,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'gender': gender.toString(),
      'race_id': raceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'] ?? '',
      bibNumber: map['bib_number'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      age: map['age'] ?? 0,
      gender: Gender.values.firstWhere(
        (gender) => gender.toString() == map['gender'],
        orElse: () => Gender.other,
      ),
      raceId: map['race_id'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  factory Participant.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    data['id'] = snapshot.id;
    return Participant.fromMap(data);
  }

  Participant copyWith({
    String? bibNumber,
    String? firstName,
    String? lastName,
    int? age,
    Gender? gender,
    String? raceId,
  }) {
    return Participant(
      id: id,
      bibNumber: bibNumber ?? this.bibNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      raceId: raceId ?? this.raceId,
      createdAt: createdAt,
    );
  }
}
