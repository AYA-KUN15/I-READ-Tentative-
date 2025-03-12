import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreReadComp {
  final String userId;

  FirestoreReadComp(this.userId);

  // Fetch user-specific module progress
  Future<DocumentSnapshot> getUserProgress(String moduleId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(moduleId)
        .get();
  }

  // Update user-specific module progress
  Future<void> updateUserProgress(
      String moduleId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(moduleId)
        .set(data, SetOptions(merge: true));
  }
}
