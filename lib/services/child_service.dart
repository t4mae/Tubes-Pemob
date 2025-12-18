import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child.dart';

class ChildService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addChild(String userId, Child child) async {
    await _firestore.collection('users').doc(userId)
        .collection('children')
        .add(child.toMap());
  }

  Future<List<Child>> getChildren(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('children')
        .get();

    return snapshot.docs
        .map((doc) => Child.fromMap(doc.data(), doc.id))
        .toList();
  }

}
