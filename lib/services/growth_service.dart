import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/growth.dart';

class GrowthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Growth>> getGrowths(String childId) async {
    final snapshot = await _firestore.collection('growths')
        .where('childId', isEqualTo: childId)
        .get();

    return snapshot.docs
        .map((doc) => Growth.fromMap(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> addGrowth(String childId, Growth growth) async {
    // Ensure childId is set in the map being sent
    var data = growth.toMap();
    data['childId'] = childId;
    await _firestore.collection('growths').add(data);
  }

  Future<void> updateGrowth(Growth growth) async {
    if (growth.id == null) return;
    await _firestore.collection('growths').doc(growth.id).update(growth.toMap());
  }
}
