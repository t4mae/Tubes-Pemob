import 'package:cloud_firestore/cloud_firestore.dart';

class Growth {
  final String? id;
  final String? childId;
  final DateTime date;
  final double weight;     // kg
  final double height;     // cm
  final double headCirc;   // lingkar kepala cm

  Growth({
    this.id,
    this.childId,
    required this.date,
    required this.weight,
    required this.height,
    required this.headCirc,
  });

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'height': height,
      'headCirc': headCirc,
    };
  }

  factory Growth.fromMap(Map<String, dynamic> map, String id) {
    return Growth(
      id: id,
      childId: map['childId'],
      date: (map['date'] as Timestamp).toDate(),
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      headCirc: (map['headCirc'] as num).toDouble(),
    );
  }
}
