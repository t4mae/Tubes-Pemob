import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child.dart';

class ChildData {
  static final ValueNotifier<List<Child>> childrenListNotifier = ValueNotifier<List<Child>>([]);
  static final ValueNotifier<Child?> currentChildNotifier = ValueNotifier<Child?>(null);

  // Getter for backward compatibility and convenience
  static List<Child> get childrenList => childrenListNotifier.value;
  static set childrenList(List<Child> newList) => childrenListNotifier.value = newList;

  static Child? get currentChild => currentChildNotifier.value;
  static set currentChild(Child? child) => currentChildNotifier.value = child;

  static Future<void> loadAllChildren() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('children')
        .get();

    final newList = snapshot.docs.map((doc) {
      return Child.fromMap(doc.data(), doc.id);
    }).toList();

    childrenList = newList;

    if (newList.isNotEmpty) {
      if (currentChild == null) {
        currentChild = newList.first;
      } else {
        // Sync instance
        final match = newList.where((c) => c.id == currentChild!.id);
        if (match.isNotEmpty) {
          currentChild = match.first;
        } else {
          currentChild = newList.first;
        }
      }
    }
  }
}
