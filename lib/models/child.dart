import 'package:cloud_firestore/cloud_firestore.dart';

class Child {
  final String? id;
  final String name;
  final DateTime birthDate;
  final String gender; // "L" or "P"

  Child({
    this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender,
    };
  }

  factory Child.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    return Child(
      id: id,
      name: map['name'] ?? '',
      birthDate: parseDate(map['birthDate']),
      gender: map['gender'] ?? 'L',
    );
  }
}
